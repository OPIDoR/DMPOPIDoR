# frozen_string_literal: true

# == Schema Information
#
# Table name: templates
#
#  id               :integer          not null, primary key
#  archived         :boolean
#  context          :integer          default("research_project"), not null
#  customization_of :integer
#  description      :text
#  is_default       :boolean
#  is_recommended   :boolean          default(FALSE)
#  links            :text
#  locale           :string
#  published        :boolean
#  title            :string
#  type             :integer          default("classic"), not null
#  version          :integer
#  visibility       :integer
#  created_at       :datetime
#  updated_at       :datetime
#  family_id        :integer
#  org_id           :integer
#
# Indexes
#
#  templates_customization_of_version_org_id_key  (customization_of,version,org_id) UNIQUE
#  templates_family_id_version_key                (family_id,version) UNIQUE
#  templates_org_id_idx                           (org_id)
#
# Foreign Keys
#
#  fk_rails_...  (org_id => orgs.id)
#

# Object that represents a DMP template
# rubocop:disable Metrics/ClassLength
class Template < ApplicationRecord
  include GlobalHelpers
  extend UniqueRandom

  validates_with TemplateLinksValidator

  # A standard template should be organisationally visible. Funder templates
  # that are meant for external use will be publicly visible. This allows a
  # funder to create 'funder' as well as organisational templates. The default
  # template should also always be publicly_visible.
  enum :visibility, %i[organisationally_visible publicly_visible]

  # --------------------------------
  # Start DMP OPIDoR Customization
  # --------------------------------
  # A classic template will have access to question types such as text, textarea
  # date, number ...
  # For structured templates, question types will be restricted to structured, with
  # access to structured forms when adding a new question.
  # Module templates can only have one phase, have a data_type & can't be used by a plan
  self.inheritance_column = nil
  enum :type, %i[classic structured module]
  # Context describes if the DMP is for a Research Project ou a Research Entity
  # The Project Form is replaced by a Structure Form in the General information tab.
  # New features might be added in the future
  enum :context, %i[research_project research_entity]
  # --------------------------------
  # End DMP OPIDoR Customization
  # --------------------------------

  # Stores links as an JSON object:
  # {funder: [{"link":"www.example.com","text":"foo"}, ...],
  #  sample_plan: [{"link":"www.example.com","text":"foo"}, ...]}
  #
  # The links is validated against custom validator allocated at
  # validators/template_links_validator.rb
  attribute :links, :text, default: { funder: [], sample_plan: [] }
  serialize :links, coder: JSON

  attribute :published, :boolean, default: false
  attribute :archived, :boolean, default: false
  attribute :is_default, :boolean, default: false
  attribute :version, :integer, default: 0
  attribute :customization_of, :integer, default: nil
  attribute :family_id, :integer, default: -> { Template.new_family_id }
  attribute :visibility, default: Template.visibilities[:organisationally_visible]

  # ================
  # = Associations =
  # ================

  belongs_to :org, optional: true

  has_many :plans

  has_many :phases, dependent: :destroy

  has_many :sections, through: :phases

  has_many :questions, through: :sections

  has_many :annotations, through: :questions

  has_many :question_options, through: :questions

  has_many :conditions, through: :questions

  # ===============
  # = Validations =
  # ===============

  validates :title, presence: { message: PRESENCE_MESSAGE }

  validates :org, presence: { message: PRESENCE_MESSAGE }, unless: proc { |t| t.module? } # rubocop:disable Style/SymbolProc

  validates :locale, presence: { message: PRESENCE_MESSAGE }

  validates :version, presence: { message: PRESENCE_MESSAGE },
                      uniqueness: { message: UNIQUENESS_MESSAGE,
                                    scope: :family_id }

  validates :visibility, presence: { message: PRESENCE_MESSAGE }

  validates :family_id, presence: { message: PRESENCE_MESSAGE }

  # =============
  # = Callbacks =
  # =============

  # TODO: leaving this in for now, as this is better placed as an after_update than
  # overwriting the accessors.  We want to ensure this template is published
  # before we remove the published_version
  # That being said, there's a potential race_condition where we have multiple-published-versions
  after_update :reconcile_published, if: ->(template) { template.published? } # rubocop:disable Style/SymbolProc

  # ==========
  # = Scopes =
  # ==========

  scope :archived, -> { where(archived: true) }

  scope :unarchived, -> { where(archived: false) }

  scope :published, lambda { |family_id = nil|
    if family_id.present?
      unarchived.where(published: true, family_id: family_id)
    else
      unarchived.where(published: true)
    end
  }

  # Retrieves the latest templates, i.e. those with maximum version associated.
  # It can be filtered down if family_id is passed
  scope :latest_version, lambda { |family_id = nil|
    unarchived.from(latest_version_per_family(family_id), :current)
              .joins(<<~SQL)
                INNER JOIN templates ON current.version = templates.version
                  AND current.family_id = templates.family_id
                INNER JOIN orgs ON orgs.id = templates.org_id
              SQL
  }

  scope :latest_module_version, lambda { |family_id = nil|
    unarchived.where(type: 'module').from(latest_version_per_family(family_id), :current)
              .joins(<<~SQL)
                INNER JOIN templates ON current.version = templates.version
                  AND current.family_id = templates.family_id
              SQL
  }

  # Retrieves the latest customized versions, i.e. those with maximum version
  # associated for a set of family_id and an org
  scope :latest_customized_version, lambda { |family_id = nil, org_id = nil|
    unarchived
      .from(latest_customized_version_per_customised_of(family_id, org_id),
            :current)
      .joins(<<~SQL)
        INNER JOIN templates ON current.version = templates.version
          AND current.customization_of = templates.customization_of
        INNER JOIN orgs ON orgs.id = templates.org_id
      SQL
      .where(templates: { org_id: org_id })
  }

  # Retrieves the latest templates, i.e. those with maximum version associated
  # for a set of org_id passed
  scope :latest_version_per_org, lambda { |org_id = nil|
    family_ids = if org_id.respond_to?(:each)
                   families(org_id).pluck(:family_id)
                 else
                   families([org_id]).pluck(:family_id)
                 end
    latest_version(family_ids)
  }

  # Retrieve all of the latest customizations for the specified org
  scope :latest_customized_version_per_org, lambda { |org_id = nil|
    family_ids = families(org_id).pluck(:family_id)
    latest_customized_version(family_ids, org_id)
  }

  # Retrieves templates with distinct family_id. It can be filtered down if
  # org_id is passed
  scope :families, lambda { |org_id = nil|
    if org_id.respond_to?(:each)
      unarchived.where(org_id: org_id).distinct
    else
      unarchived.distinct
    end
  }

  # Retrieves the latest version of each customizable funder template (and the
  # default template)
  scope :latest_customizable, lambda {
    funder_ids = Org.funder.pluck(:id)
    family_ids = families(funder_ids).distinct
                                     .pluck(:family_id) + [default.family_id]
    published(family_ids.uniq)
      .where('type = :type AND visibility = :visibility OR is_default = :is_default',
             type: types[:classic],
             visibility: visibilities[:publicly_visible], is_default: false)
  }

  # Retrieves unarchived templates with public visibility
  # Overwrites the default method from the enum
  scope :publicly_visible, lambda {
    unarchived.where(visibility: visibilities[:publicly_visible])
  }

  # Retrieves unarchived templates with organisational visibility
  # Overwrites the default method from the enum
  scope :organisationally_visible, lambda {
    unarchived.where(visibility: visibilities[:organisationally_visible])
  }

  # Retrieves unarchived templates whose title or org.name includes the term
  # passed(We use search_term_orgs as alias for orgs to avoid issues with
  # any orgs table join already present in loaded unarchived.)
  scope :search, lambda { |term|
    unarchived
      .joins(<<~SQL)
        JOIN orgs AS search_term_orgs ON search_term_orgs.id = templates.org_id
      SQL
      .where('lower(templates.title) LIKE lower(:term)' \
             'OR lower(search_term_orgs.name) LIKE lower(:term)',
             term: "%#{term}%")
  }

  # defines the export setting for a template object
  has_settings :export, class_name: 'Settings::Template' do |s|
    s.key :export, defaults: Settings::Template::DEFAULT_SETTINGS
  end

  # =================
  # = Class Methods =
  # =================

  def self.default
    where(is_default: true, published: true).last
  end

  def self.recommend(context: 'research_project', locale: 'fr-FR')
    where(is_recommended: true, published: true, type: 'structured', context:, locale:).last
  end

  def self.module(data_type: nil, locale: 'fr-FR')
    return nil if data_type.nil?

    where(published: true, type: 'module', data_type:, locale:).last
  end

  def self.current(family_id)
    unarchived.where(family_id: family_id).order(version: :desc).first
  end

  def self.live(family_id)
    if family_id.respond_to?(:each)
      unarchived.where(family_id: family_id, published: true)
    else
      unarchived.where(family_id: family_id, published: true).first
    end
  end

  def self.find_or_generate_version!(template)
    if template.latest? && template.generate_version?
      template.generate_version!
    elsif template.latest? && !template.generate_version?
      template
    else
      raise _('A historical template cannot be retrieved for being modified')
    end
  end

  # Retrieves the latest templates, i.e. those with maximum version associated.
  # It can be filtered down if family_id is passed. NOTE, the template objects
  # instantiated only contain version and family attributes populated. See
  # Template::latest_version scope method for an adequate instantiation of
  # template instances.
  def self.latest_version_per_family(family_id = nil)
    chained_scope = unarchived.select('MAX(version) AS version', :family_id)
    chained_scope = chained_scope.where(family_id: family_id) if family_id.present?
    chained_scope.group(:family_id)
  end

  def self.latest_customized_version_per_customised_of(customization_of = nil,
                                                       org_id = nil)
    chained_scope = select('MAX(version) AS version', :customization_of)
    chained_scope = chained_scope.where(customization_of: customization_of)
    chained_scope = chained_scope.where(org_id: org_id) if org_id.present?
    chained_scope.group(:customization_of)
  end

  # ===========================
  # = Public instance methods =
  # ===========================

  # Creates a copy of the current template
  # raises ActiveRecord::RecordInvalid when save option is true and validations
  # fails.
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def deep_copy(attributes: {}, **options)
    copy = dup
    if attributes.respond_to?(:each_pair)
      attributes.each_pair do |attribute, value|
        copy.send(:"#{attribute}=", value) if copy.respond_to?(:"#{attribute}=")
      end
    end
    copy.save! if options.fetch(:save, false)
    options[:template_id] = copy.id
    phases.each { |phase| copy.phases << phase.deep_copy(**options) }
    # transfer the conditions to the new template
    #  done here as the new questions are not accessible when the conditions deep copy
    copy.conditions.each do |cond|
      if cond.option_list.any?
        versionable_ids = QuestionOption.where(id: cond.option_list).pluck(:versionable_id)
        cond.option_list = copy.question_options.where(versionable_id: versionable_ids)
                               .pluck(:id).map(&:to_s)
        # TODO: these seem to be stored as strings, not sure if that's required by other code
        # TODO: would it be safe to remove conditions without an option list?
      end

      if cond.remove_data.any?
        versionable_ids = Question.where(id: cond.remove_data).pluck(:versionable_id)
        cond.remove_data = copy.questions.where(versionable_id: versionable_ids)
                               .pluck(:id).map(&:to_s)
      end

      cond.save if cond.changed?
    end

    copy
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  # Retrieves the template's org or the org of the template this one is derived
  # from of it is a customization
  def base_org
    if customization_of.present?
      Template.where(family_id: customization_of).first.org
    else
      org
    end
  end

  # Is this the latest version of the current Template's family?
  #
  # Returns Boolean
  # CHANGES : Added module template support
  def latest?
    id == if module?
            Template.latest_module_version(family_id).pluck('templates.id').first
          else
            Template.latest_version(family_id).pluck('templates.id').first
          end
  end

  # Determines whether or not a new version should be generated
  def generate_version?
    published
  end

  # Determines whether or not a customization for the customizing_org passed
  # should be generated
  def customize?(customizing_org)
    if customizing_org.is_a?(Org) && (org.funder_only? || is_default)
      return !Template.unarchived.where(customization_of: family_id,
                                        org: customizing_org).exists?
    end
    false
  end

  # Determines whether or not a customized template should be upgraded
  def upgrade_customization?
    return false unless customization_of?

    funder_template = Template.published(customization_of).select(:created_at).first
    return false unless funder_template.present?

    funder_template.created_at > created_at
  end

  # Checks to see if the template family has a published version and if its not
  # the current template
  def draft?
    !published && !Template.published(family_id).empty?
  end

  # CHANGES : Added module template support
  def removable?
    versions = Template.includes(:plans).where(family_id: family_id)
    if type.eql?('module')
      Fragment::ResearchOutput.where("(additional_info->>'moduleId')::int IN (?)", versions.pluck(:id)).empty?
    else
      versions.reject { |version| version.plans.empty? }.empty?
    end
  end

  # Returns a new unpublished copy of self with a new family_id, version = zero
  # for the specified org
  def generate_copy!(org)
    # Assume customizing_org is persisted
    raise _('generate_copy! requires an organisation target') unless org.is_a?(Org)

    args = {
      attributes: {
        version: 0,
        published: false,
        family_id: new_family_id,
        org: org,
        is_default: false,
        title: format(_('Copy of %{template}'), template: title)
      }, modifiable: true, save: true
    }
    deep_copy(**args)
  end

  # Generates a new copy of self with an incremented version number
  def generate_version!
    raise _('generate_version! requires a published template') unless published

    args = {
      attributes: {
        version: version + 1,
        published: false,
        org: org
      }, save: true
    }
    deep_copy(**args)
  end

  # Generates a new copy of self for the specified customizing_org
  def customize!(customizing_org)
    # Assume customizing_org is persisted
    raise ArgumentError, _('customize! requires an organisation target') unless customizing_org.is_a?(Org)

    # Assume self has org associated
    raise ArgumentError, _('customize! requires a template from a funder') if !org.funder_only? && !is_default

    args = {
      attributes: {
        version: 0,
        published: false,
        family_id: new_family_id,
        customization_of: family_id,
        org: customizing_org,
        visibility: Template.visibilities[:organisationally_visible],
        is_default: false
      }, modifiable: false, save: true
    }
    deep_copy(**args)
  end

  # Generates a new copy of self including latest changes from the funder this
  # template is customized_of
  def upgrade_customization!
    Template::UpgradeCustomizationService.call(self)
  end

  def publish
    update(published: true)
  end

  def publish!
    update!(published: true)
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def publishability
    error = ''
    publishable = true
    # template must be the most recent draft
    if published
      error += _('You can not publish a published template.  ')
      publishable = false
    end
    unless latest?
      error += _('You can not publish a historical version of this template.  ')
      publishable = false
      # all templates have atleast one phase
    end
    if phases.count <= 0
      error += _('You can not publish a template without phases.  ')
      publishable = false
      # all phases must have atleast 1 section
    end
    unless phases.map { |p| p.sections.count.positive? }.reduce(true) { |fin, val| fin && val }
      error += _('You can not publish a template without sections in a phase.  ')
      publishable = false
      # all sections must have atleast one question
    end
    unless sections.map { |s| s.questions.count.positive? }.reduce(true) { |fin, val| fin && val }
      error += _('You can not publish a template without questions in a section.  ')
      publishable = false
    end
    if invalid_condition_order
      error += _('Conditions in the template refer backwards')
      publishable = false
    end
    [publishable, error]
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  # TODO: refactor to use UniqueRandom
  # Generate a new random family identifier
  def self.new_family_id
    loop do
      random = rand 2_147_483_647
      break random unless Template.exists?(family_id: random)
    end
  end

  def serialize_json
    section_data = sections.as_json(
      include: {
        questions: {
          only: %w[id text number default_value question_format_id],
          include: { madmp_schema: { only: %w[id classname] } }
        }
      }
    )
    {
      id: id,
      locale: locale,
      title: title,
      version: version,
      org: org&.name,
      structured: structured?,
      publishedDate: updated_at.to_date,
      sections: section_data
    }
  end

  private

  # ============================
  # = Private instance methods =
  # ============================

  def new_family_id
    Template.new_family_id
  end

  # Only one version of a template should be published at a time, so if this
  # one was published make sure other versions are not
  def reconcile_published
    # Unpublish all other versions of this template family
    Template.published
            .where(family_id: family_id)
            .where.not(id: id)
            .update_all(published: false)
  end

  def invalid_condition_order
    questions.each do |question|
      next unless question.option_based?

      question.conditions.each do |condition|
        next unless condition.action_type == 'remove'

        condition.remove_data.each do |rem_id|
          rem_question = Question.find(rem_id.to_s)
          return true if before(rem_question, question)
        end
      end
    end
    false
  end

  def before(question1, question2)
    question1.section.number < question2.section.number ||
      (question1.section.number == question2.section.number && question1.number < question2.number)
  end
end
# rubocop:enable Metrics/ClassLength
