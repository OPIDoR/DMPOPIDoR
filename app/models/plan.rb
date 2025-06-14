# frozen_string_literal: true

# The central model object within this domain. Represents a Data Management
# Plan for a research project.
#
# == Schema Information
#
# Table name: plans
#
#  id                         :integer          not null, primary key
#  complete                   :boolean          default(FALSE)
#  description                :text
#  end_date                   :datetime
#  ethical_issues             :boolean
#  ethical_issues_description :text
#  ethical_issues_report      :string
#  feedback_request_date      :datetime
#  feedback_requested         :boolean          default(FALSE)
#  funding_status             :integer
#  identifier                 :string
#  start_date                 :datetime
#  title                      :string
#  visibility                 :integer          default("administrator_visible"), not null
#  created_at                 :datetime
#  updated_at                 :datetime
#  feedback_requestor_id      :integer
#  funder_id                  :integer
#  grant_id                   :integer
#  org_id                     :integer
#  template_id                :integer
#
# Indexes
#
#  index_plans_on_funder_id           (funder_id)
#  index_plans_on_grant_id            (grant_id)
#  index_plans_on_org_id              (org_id)
#  plans_template_id_idx              (template_id)
#
# Foreign Keys
#
#  fk_rails_...  (org_id => orgs.id)
#  fk_rails_...  (template_id => templates.id)
#

# Object that represents an DMP
# rubocop:disable Metrics/ClassLength
class Plan < ApplicationRecord
  include ConditionalUserMailer
  include ExportablePlan
  include DateRangeable
  include Identifiable

  # =============
  # = Constants =
  # =============

  DMP_ID_TYPES = %w[ark doi].freeze

  # Returns visibility message given a Symbol type visibility passed, otherwise
  # nil
  VISIBILITY_MESSAGE = {
    organisationally_visible: 'organisational',
    publicly_visible: 'public',
    is_test: 'test',
    # --------------------------------
    # Start DMP OPIDoR Customization
    # CHANGES : Administrator visibility
    # --------------------------------
    administrator_visible: 'Administrator',
    # --------------------------------
    # End DMP OPIDoR Customization
    # --------------------------------
    privately_visible: 'private'
  }.freeze

  FUNDING_STATUS = {
    planned: _('Planned'),
    funded: _('Funded'),
    denied: _('Denied')
  }.freeze

  # ==============
  # = Attributes =
  # ==============

  # public is a Ruby keyword so using publicly
  enum :visibility, %i[organisationally_visible publicly_visible
                       is_test administrator_visible privately_visible]

  enum :funding_status, %i[planned funded denied]

  alias_attribute :name, :title

  # ================
  # = Associations =
  # ================

  belongs_to :template

  belongs_to :org, optional: true

  belongs_to :funder, class_name: 'Org', optional: true

  belongs_to :api_client, optional: true

  has_many :phases, through: :template

  has_many :sections, through: :phases

  has_many :questions, through: :sections

  has_many :themes, through: :questions

  has_many :guidances, through: :themes

  has_many :guidance_group_options, -> { distinct.includes(:org).published.reorder('id') },
           through: :guidances,
           source: :guidance_group,
           class_name: 'GuidanceGroup'

  has_many :answers, dependent: :destroy

  has_many :notes, through: :answers

  has_many :roles, dependent: :destroy

  has_many :users, through: :roles

  has_and_belongs_to_many :guidance_groups, join_table: :plans_guidance_groups

  has_many :exported_plans, dependent: :destroy

  # --------------------------------
  # Start DMP OPIDoR Customization
  # CHANGES : Research outputs & Feedback requestor
  # --------------------------------
  has_many :research_outputs, dependent: :destroy, inverse_of: :plan do
    # Returns the default research output
    def default
      find_by(is_default: true)
    end
  end

  belongs_to :feedback_requestor, class_name: 'User', foreign_key: 'feedback_requestor_id', optional: true

  has_many :api_client_roles, dependent: :destroy

  has_many :api_clients, through: :api_client_roles
  # --------------------------------
  # End DMP OPIDoR Customization
  # --------------------------------

  has_many :contributors, dependent: :destroy

  has_one :grant, as: :identifiable, dependent: :destroy, class_name: 'Identifier'

  has_many :research_outputs, dependent: :destroy

  # =====================
  # = Nested Attributes =
  # =====================

  accepts_nested_attributes_for :template

  accepts_nested_attributes_for :roles

  accepts_nested_attributes_for :contributors

  # --------------------------------
  # Start DMP OPIDoR Customization
  # CHANGES : Research outputs
  # --------------------------------
  accepts_nested_attributes_for :research_outputs, reject_if: :all_blank, allow_destroy: true
  # --------------------------------
  # End DMP OPIDoR Customization
  # --------------------------------

  # ===============
  # = Validations =
  # ===============

  validates :title, presence: { message: PRESENCE_MESSAGE }

  validates :template, presence: { message: PRESENCE_MESSAGE }

  validates :feedback_requested, inclusion: { in: BOOLEAN_VALUES }

  validates :complete, inclusion: { in: BOOLEAN_VALUES }

  validate :end_date_after_start_date

  # ==========
  # = Scopes =
  # ==========

  # Retrieves any plan in which the user has an active role and
  # is not a reviewer
  scope :active, lambda { |user|
    plan_ids = Role.where(active: true, user_id: user.id).pluck(:plan_id)

    includes(:template, :roles)
      .where(id: plan_ids)
  }

  # Retrieves any plan in which the user has an active role and
  # is not a reviewer
  scope :owner_or_coowner, lambda { |user|
    plan_ids = Role.administrator.where(active: true, user_id: user.id).pluck(:plan_id)

    includes(:template, :roles)
      .where(id: plan_ids)
  }

  # Retrieves any plan organisationally or publicly visible for a given org id
  scope :organisationally_or_publicly_visible, lambda { |user|
    # --------------------------------
    # Start DMP OPIDoR Customization
    # CHANGES : Removed 'complete' criteria for organisationally_or_publicly_visible plans
    # --------------------------------
    plan_ids = user.org.org_admin_plans.pluck(:id).uniq
    # --------------------------------
    # End DMP OPIDoR Customization
    # --------------------------------
    includes(:template, roles: :user)
      .where(id: plan_ids, visibility: [
               visibilities[:organisationally_visible],
               visibilities[:publicly_visible]
             ])
      .where(
        'NOT EXISTS (SELECT 1 FROM roles WHERE plan_id = plans.id AND user_id = ?)',
        user.id
      )
  }

  # --------------------------------
  # Start DMP OPIDoR Customization
  # CHANGES : Org admin can view all plans except private visibility
  # --------------------------------
  scope :org_admin_visible, lambda { |user|
    plan_ids = Role.where(active: true, user_id: user.id).pluck(:plan_id)

    includes(:template, roles: :user)
      .where(id: plan_ids, visibility: [
               visibilities[:administrator_visible],
               visibilities[:organisationally_visible],
               visibilities[:publicly_visible]
             ])
  }
  # --------------------------------
  # End DMP OPIDoR Customization
  # --------------------------------

  # TODO: Add in a left join here so we can search contributors as well when
  #       we move to Rails 5:
  #           OR lower(contributors.name) LIKE lower(:search_pattern)
  #           OR lower(identifiers.value) LIKE lower(:search_pattern)",
  scope :search, lambda { |term|
    if date_range?(term: term)
      joins(:template, roles: [user: :org])
        .where(roles: { active: true })
        .by_date_range(:created_at, term)
    else
      search_pattern = "%#{term}%"
      joins(:template, roles: [user: :org])
        .left_outer_joins(:identifiers, :contributors)
        .where(roles: { active: true })
        .where("lower(plans.title) LIKE lower(:search_pattern)
                OR lower(orgs.name) LIKE lower (:search_pattern)
                OR lower(orgs.abbreviation) LIKE lower (:search_pattern)
                OR lower(templates.title) LIKE lower(:search_pattern)
                OR lower(contributors.name) LIKE lower(:search_pattern)
                OR lower(identifiers.value) LIKE lower(:search_pattern)",
               search_pattern: search_pattern)
    end
  }

  ##
  # Defines the filter_logic used in the statistics objects.
  # For now, we filter out any test plans
  scope :stats_filter, -> { where.not(visibility: visibilities[:is_test]) }

  # Retrieves plan, template, org, phases, sections and questions
  scope :overview, lambda { |id|
    includes(:phases, :sections, :questions, template: [:org]).find(id)
  }

  ##
  # Settings for the template
  has_settings :export, class_name: 'Settings::Template' do |s|
    s.key :export, defaults: Settings::Template::DEFAULT_SETTINGS
  end
  alias super_settings settings

  # =============
  # = Callbacks =
  # =============

  # sanitise html tags e.g remove unwanted 'script'
  before_validation lambda { |data|
    data.sanitize_fields(:title, :identifier, :description)
  }

  # =================
  # = Class methods =
  # =================

  # --------------------------------
  # Start DMP OPIDoR Customization
  # CHANGES: Added PRELOAD for madmp_schema & research_output
  # --------------------------------
  # Pre-fetched a plan phase together with its sections and questions
  # associated. It also pre-fetches the answers and notes associated to the plan
  def self.load_for_phase(plan_id, phase_id)
    # Preserves the default order defined in the model relationships
    plan = Plan.joins(:research_outputs, template: { phases: { sections: :questions } })
               .preload(:research_outputs, template: { phases: { sections: :questions } })
               .where(id: plan_id, phases: { id: phase_id })
               .merge(Plan.includes(answers: :notes)).first
    phase = plan.template.phases.find { |p| p.id == phase_id.to_i }

    [plan, phase]
  end
  # --------------------------------
  # End DMP OPIDoR Customization
  # --------------------------------

  # --------------------------------
  # Start DMP OPIDoR Customization
  # CHANGES:
  #   - Added Research Output Support
  #   - Added Project/Meta/ResearchOutput Fragments copy
  # --------------------------------
  # deep copy the given plan and all of it's associations
  # create
  # plan - Plan to be deep copied
  #
  # Returns Plan
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def self.deep_copy(plan)
    plan_copy = plan.dup
    I18n.with_locale plan.template.locale do
      plan_copy.title = format(_('Copy of %{title}'), title: plan.title)
      plan_copy.feedback_requested = false
      plan_copy.save!
      plan_copy.copy_plan_fragments(plan)
      plan.research_outputs.each do |research_output|
        research_output_copy = ResearchOutput.deep_copy(research_output)
        research_output_copy.title = research_output.title || format(_('Copy of %{title}'),
                                                                     title: research_output.abbreviation)
        research_output_copy.plan_id = plan_copy.id
        research_output_copy.save!
        research_output_copy.create_json_fragments

        research_output_description = research_output.json_fragment.research_output_description
        research_output_copy.json_fragment.research_output_description.raw_import(
          research_output_description.get_full_fragment,
          research_output_description.madmp_schema
        )

        research_output.answers.each do |answer|
          answer_copy = Answer.deep_copy(answer)
          answer_copy.plan_id = plan_copy.id
          answer_copy.research_output_id = research_output_copy.id
          answer_copy.save!
        end
      end
    end
    plan.guidance_groups.each do |guidance_group|
      plan_copy.guidance_groups << guidance_group if guidance_group.present?
    end
    plan_copy
  end
  # --------------------------------
  # End DMP OPIDoR Customization
  # --------------------------------
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def self.structured_deep_copy(plan)
    plan_copy = plan.dup
    I18n.with_locale plan.template.locale do
      plan_copy.title = format(_('Copy of %{title}'), title: plan.title)
      plan_copy.feedback_requested = false
      plan_copy.save!
      plan_copy.copy_plan_fragments(plan)
      plan.research_outputs.each do |research_output|
        research_output_copy = ResearchOutput.deep_copy(research_output)
        research_output_copy.title = research_output.title || format(_('Copy of %{title}'),
                                                                     title: research_output.abbreviation)
        research_output_copy.plan_id = plan_copy.id
        research_output_copy.save!
        # Creates the main ResearchOutput fragment
        ro_fragment = Fragment::ResearchOutput.create(
          data: {
            'research_output_id' => research_output_copy.id
          },
          madmp_schema: MadmpSchema.find_by(classname: 'research_output'),
          dmp_id: plan_copy.json_fragment.id,
          parent_id: plan_copy.json_fragment.id,
          additional_info: research_output.json_fragment.additional_info
        )

        research_output.answers.each do |answer|
          answer_copy = Answer.deep_copy(answer)
          answer_copy.plan_id = plan_copy.id
          answer_copy.research_output_id = research_output_copy.id
          answer_copy.save!
          MadmpFragment.deep_copy(answer.madmp_fragment, answer_copy.id, ro_fragment) if plan.structured?
        end
      end
    end
    plan.guidance_groups.each do |guidance_group|
      plan_copy.guidance_groups << guidance_group if guidance_group.present?
    end
    plan_copy
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  # ===========================
  # = Public instance methods =
  # ===========================

  ##
  # Proxy through to the template settings (or defaults if this plan doesn't
  # have an associated template) if there are no settings stored for this plan.
  #
  # TODO: Update this comment below. AFAIK `key` has nothing to do with Rails.
  # key - Is required by rails-settings, so it's required here, too.
  #
  # Returns Hash
  def settings(key)
    self_settings = super_settings(key)
    return self_settings if self_settings.value?

    template&.settings(key)
  end

  # The most recent answer to the given question id optionally can create an answer if
  # none exists.
  #
  # qid               - The id for the question to find the answer for
  # create_if_missing - If true, will genereate a default answer
  #                     to the question (defaults: true).
  #
  # Returns Answer
  # Returns nil
  # CHANGES : ADDED RESEARCH OUTPUT SUPPORT
  # rubocop:disable Metrics/AbcSize, Style/OptionalBooleanParameter
  # rubocop:disable Metrics/CyclomaticComplexity
  def answer(qid, create_if_missing = true, roid = nil)
    answer = answers.select { |a| a.question_id == qid && a.research_output_id == roid }
                    .max_by(&:created_at)
    if answer.nil? && create_if_missing
      question           = Question.find(qid)
      answer             = Answer.new
      answer.plan_id     = id
      answer.question_id = qid
      answer.text        = question.default_value
      default_options    = []
      question.question_options.each do |option|
        default_options << option if option.is_default
      end
      answer.question_options = default_options
    end
    answer
  end
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/AbcSize, Style/OptionalBooleanParameter

  alias get_guidance_group_options guidance_group_options

  deprecate :get_guidance_group_options,
            deprecator: Cleanup::Deprecators::GetDeprecator.new

  ##
  # Sets up the plan for feedback:
  #  emails confirmation messages to owners
  #  emails org admins and org contact
  #  adds org admins to plan with the 'reviewer' Role
  # rubocop:disable Metrics/AbcSize
  def request_feedback(user)
    Plan.transaction do
      self.feedback_requested = true
      # --------------------------------
      # Start DMP OPIDoR Customization
      # CHANGES : Added feedback_requestor & request_date columns
      # --------------------------------
      self.feedback_requestor_id = user.id
      self.feedback_request_date = DateTime.current
      # --------------------------------
      # End DMP OPIDoR Customization
      # --------------------------------
      return false unless save!

      # Send an email to the org-admin contact
      if user.org.contact_email.present?
        contact = User.new(email: user.org.contact_email,
                           firstname: user.org.contact_name)
        UserMailer.feedback_notification(contact, self, user).deliver_now
      end
      true
    rescue StandardError => e
      Rails.logger.error e
      false
    end
  end
  # rubocop:enable Metrics/ClassLength
  # --------------------------------
  # End DMP OPIDoR Customization
  # --------------------------------

  ##
  # Finalizes the feedback for the plan: Emails confirmation messages to owners
  # sets flag on plans.feedback_requested to false removes org admins from the
  # 'reviewer' Role for the Plan.
  def complete_feedback(org_admin)
    Plan.transaction do
      self.feedback_requested = false
      # --------------------------------
      # Start DMP OPIDoR Customization
      # CHANGES : Added feedback_requestor & request_date columns
      # --------------------------------
      self.feedback_requestor_id = nil
      self.feedback_request_date = nil
      # --------------------------------
      # End DMP OPIDoR Customization
      # --------------------------------
      return false unless save!

      # Send an email confirmation to the owners and co-owners
      deliver_if(recipients: owner_and_coowners,
                 key: 'users.feedback_provided') do |r|
        UserMailer.feedback_complete(
          r,
          self,
          org_admin
        ).deliver_now
      end
      true
    rescue StandardError => e
      Rails.logger.error e
      false
    end
  end

  ##
  # determines if the plan is editable by the specified user
  #
  # user_id - The id for a user
  #
  # Returns Boolean
  def editable_by?(user_id)
    roles.any? { |r| r.user_id == user_id && r.active && r.editor }
  end

  ##
  # determines if the plan is readable by the specified user
  #
  # user_id - The Integer id for a user
  #
  # Returns Boolean
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def readable_by?(user_id)
    return true if commentable_by?(user_id)

    current_user = User.find(user_id)
    return false unless current_user.present?

    # If the user is a super admin and the config allows for supers to view plans
    if current_user.can_super_admin? && Rails.configuration.x.plans.super_admins_read_all
      true
    # If the user is an org admin and the config allows for org admins to view plans
    elsif current_user.can_org_admin? && Rails.configuration.x.plans.org_admins_read_all
      # --------------------------------
      # Start DMP OPIDoR Customization
      # CHANGES : All plan except private one are visible by admins.
      # --------------------------------
      return false if privately_visible?

      # --------------------------------
      # End DMP OPIDoR Customization
      # --------------------------------
      owner_and_coowners.map(&:org_id).include?(current_user.org_id)
    else
      false
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  # determines if the plan is readable by the specified user.
  #
  # user_id - The Integer id for a user
  #
  # Returns Boolean
  def commentable_by?(user_id)
    roles.any? { |r| r.user_id == user_id && r.active && r.commenter } ||
      reviewable_by?(user_id)
  end

  # determines if the plan is administerable by the specified user
  #
  # user_id - The Integer id for the user
  #
  # Returns Boolean
  def administerable_by?(user_id)
    roles.any? { |r| r.user_id == user_id && r.active && r.administrator }
  end

  # determines if the plan is reviewable by the specified user
  #
  # user_id - The Integer id for the user
  #
  # Returns Boolean
  # CHANGES : Reviewer can be from a different org of the plan owner
  def reviewable_by?(user_id)
    reviewer = User.find(user_id)
    feedback_requested? &&
      reviewer.present? &&
      reviewer.org_id == feedback_requestor&.org_id &&
      reviewer.can_review_plans?
  end

  # the datetime for the latest update of this plan
  #
  # Returns DateTime
  def latest_update
    (phases.pluck(:updated_at) + [updated_at]).max
  end

  # The owner (aka :creator) of the project
  #
  # Returns User
  # Returns nil
  def owner
    r = roles.select { |rr| rr.active && rr.administrator }
             .min_by(&:created_at)
    r&.user
  end

  # Creates a role for the specified user (will update the user's
  # existing role if it already exists)
  #
  # Expects a User.id and access_type from the following list:
  #  :creator, :administrator, :editor, :commenter
  #
  # Returns Boolean
  def add_user!(user_id, access_type = :commenter)
    user = User.where(id: user_id).first
    if user.present?
      role = Role.find_or_initialize_by(user_id: user_id, plan_id: id)

      # Access is cumulative, so set the appropriate flags
      # (e.g. an administrator can also edit and comment)
      case access_type
      when :creator
        role.creator = true
        role.administrator = true
        role.editor = true
      when :administrator
        role.administrator = true
        role.editor = true
      when :editor
        role.editor = true
      end
      role.commenter = true
      role.save
    else
      false
    end
  end

  ##
  # Whether or not the plan is associated with users other than the creator
  #
  # Returns Boolean
  def shared?
    roles.select(&:active).reject(&:creator).any? || api_client_roles.reject(&:creator).any?
  end

  alias shared shared?

  deprecate :shared, deprecator: Cleanup::Deprecators::PredicateDeprecator.new

  # The owner and co-owners (aka :creator and :administrator) of the project
  #
  # Returns ActiveRecord::Relation
  def owner_and_coowners
    # We only need to search for :administrator in the bitflag
    # since :creator includes :administrator rights
    roles.select { |r| r.active && r.administrator && !r.user.nil? }.map(&:user).uniq
  end

  # The creator, administrator and editors
  #
  # Returns ActiveRecord::Relation
  def authors
    # We only need to search for :editor in the bitflag
    # since :creator and :administrator include :editor rights
    roles.select { |r| r.active && r.editor }.map(&:user).uniq
  end

  # The number of answered questions from the entire plan
  #
  # Returns Integer
  def num_answered_questions(phase = nil)
    return answers.count(&:answered?) unless phase.present?

    answered = answers.select do |answer|
      answer.answered? && phase.questions.include?(answer.question)
    end
    answered.length
  end

  # The number of questions for a plan.
  #
  # Returns Integer
  def num_questions
    questions.count
  end

  # Determines whether or not visibility changes are permitted according to the
  # percentage of the plan answered in respect to a threshold defined at
  # application.config
  #
  # Returns Boolean
  def visibility_allowed?
    !is_test? && phases.any? { |phase| phase.visibility_allowed?(self) }
  end

  # Determines whether or not a question (given its id) exists for the self plan
  #
  # Returns Boolean
  def question_exists?(question_id)
    Plan.joins(:questions).exists?(id: id, 'questions.id': question_id)
  end

  # Determines what percentage of the Plan's questions have been num_answered_questions
  #
  def percent_answered
    num_questions = question_ids.length
    return 0 unless num_questions.positive?

    pre_fetched_answers = Answer.includes(:question_options,
                                          question: :question_format)
                                .where(id: answer_ids)
    num_answers = pre_fetched_answers.reduce(0) do |m, a|
      m += 1 if a.answered?
      m
    end
    return 0 unless num_answers.positive?

    (num_answers / num_questions.to_f) * 100
  end

  # Deactivates the plan (sets all roles to inactive and visibility to :private)
  #
  # Returns Boolean
  # SEE MODULE
  def deactivate!
    # If no other :creator, :administrator or :editor is attached
    # to the plan, then also deactivate all other active roles
    # and set the plan's visibility to :private
    if authors.empty?
      roles.where(active: true).update_all(active: false)
      self.visibility = Plan.visibilities[:privately_visible]
      save!
    else
      false
    end
  end

  # Returns the plan's identifier (either a DOI/ARK)
  def landing_page
    identifiers.find { |i| DMP_ID_TYPES.include?(i.identifier_format) }
  end

  # Since the Grant is not a normal AR association, override the getter and setter
  def grant
    Identifier.find_by(id: grant_id)
  end

  # Helper method to convert the grant id value entered by the user into an Identifier
  # works with both controller params or an instance of Identifier
  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
  def grant=(params)
    val = params.present? ? params[:value] : nil
    current = grant

    # Remove it if it was blanked out by the user
    current.destroy if current.present? && !val.present?
    return unless val.present?

    # Create the Identifier if it doesn't exist and then set the id
    current.update(value: val) if current.present? && current.value != val
    return if current.present?

    current = Identifier.create(identifiable: self, value: val)
    self.grant_id = current.id
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity

  # Defines if an api client has a read access to the plan
  def readable_by_client?(client_id)
    api_client_roles.any? { |r| r.api_client_id == client_id && r.read }
  end

  # The number of research outputs for a plan.
  #
  # Returns Integer
  def num_research_outputs
    research_outputs.count
  end

  # Return the JSON Fragment linked to the Plan
  #
  # Returns JSON
  def json_fragment
    Fragment::Dmp.where("(data->>'plan_id')::int = ?", id).first
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def create_plan_fragments(json_data = nil)
    template_locale = template.locale.eql?('en-GB') ? 'eng' : 'fra'
    dmp_template_name = research_entity? ? 'DMPResearchEntity' : 'DMPResearchProject'
    # rubocop:disable Metrics/BlockLength
    I18n.with_locale template.locale do
      dmp_fragment = Fragment::Dmp.create!(
        data: {
          'plan_id' => id
        },
        madmp_schema: MadmpSchema.find_by(name: dmp_template_name),
        additional_info: {}
      )

      #################################
      # PERSON & CONTRIBUTORS FRAGMENTS
      #################################
      if owner.present?
        person = Fragment::Person.create!(
          data: {
            'nameType' => 'Personal',
            'lastName' => owner.surname,
            'firstName' => owner.firstname,
            'mbox' => owner.email
          },
          dmp_id: dmp_fragment.id,
          madmp_schema: MadmpSchema.find_by(name: 'PersonStandard'),
          additional_info: { property_name: 'person' }
        )
      end

      dmp_coordinator = Fragment::Contributor.create!(
        data: {
          'person' => person.present? ? { 'dbid' => person.id } : nil,
          'role' => _('DMP manager')
        },
        dmp_id: dmp_fragment.id,
        parent_id: nil,
        madmp_schema: MadmpSchema.find_by(name: 'ContributorConstantRole'),
        additional_info: { property_name: 'contact' }
      )

      #################################
      # META & PROJECT FRAGMENTS
      #################################
      if research_entity?
        handle_research_entity(dmp_fragment.id, json_data.present? ? json_data['research_entity'] : nil)
      else
        handle_research_project(dmp_fragment.id)
      end

      meta = Fragment::Meta.create!(
        data: {
          'title' => format(_('"%{project_title}" project DMP'), project_title: title),
          'creationDate' => created_at.strftime('%F'),
          'lastModifiedDate' => updated_at.strftime('%F'),
          'dmpLanguage' => template_locale,
          'dmpId' => identifier,
          'contact' => [{ 'dbid' => dmp_coordinator.id }]
        },
        dmp_id: dmp_fragment.id,
        parent_id: dmp_fragment.id,
        madmp_schema: MadmpSchema.find_by(name: 'MetaStandard'),
        additional_info: { property_name: 'meta' }
      )

      dmp_coordinator.update(parent_id: meta.id)
    end
    # rubocop:enable Metrics/BlockLength
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def handle_research_project(dmp_id)
    project_schema = MadmpSchema.find_by(name: 'ProjectStandard')

    Fragment::Project.create!(
      data: {
        'title' => title,
        'description' => description
      },
      dmp_id: dmp_id,
      parent_id: dmp_id,
      madmp_schema: project_schema,
      additional_info: { property_name: 'project' }
    )
  end

  def handle_research_entity(dmp_id, research_entity = nil)
    entity_schema = MadmpSchema.find_by(name: 'ResearchEntityStandard')
    Fragment::ResearchEntity.create!(
      data: if research_entity.present?
              research_entity
            else
              {
                'name' => title,
                'description' => description
              }
            end,
      dmp_id: dmp_id,
      parent_id: dmp_id,
      madmp_schema: entity_schema,
      additional_info: { property_name: 'researchEntity' }
    )
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def copy_plan_fragments(plan)
    create_plan_fragments if json_fragment.nil?

    incoming_dmp = plan.json_fragment
    I18n.with_locale plan.template.locale do
      raw_project = if plan.template.context == 'research_entity'
                      incoming_dmp.research_entity.get_full_fragment
                    else
                      incoming_dmp.project.get_full_fragment
                    end
      raw_meta = incoming_dmp.meta.get_full_fragment
      raw_meta = raw_meta.merge(
        'title' => format(_('Copy of %{title}'), title: raw_meta['title'])
      )
      incoming_dmp.persons.each do |person|
        Fragment::Person.create(
          data: person.data,
          dmp_id: json_fragment.id,
          madmp_schema: MadmpSchema.find_by(name: 'PersonStandard'),
          additional_info: { property_name: 'person' }
        )
      end

      if research_entity?
        json_fragment.research_entity.raw_import(raw_project, json_fragment.research_entity.madmp_schema)
      else
        json_fragment.project.raw_import(raw_project, json_fragment.project.madmp_schema)
      end
      json_fragment.meta.raw_import(raw_meta, json_fragment.meta.madmp_schema)
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def add_api_client!(api_client)
    return unless api_client.present? && api_client_roles.where(api_client_id: api_client.id).none?

    api_client_roles.create(
      read: true,
      api_client_id: api_client.id
    )
  end

  def grant_identifier
    if research_entity?
      json_fragment.research_entity.fundings.pluck(Arel.sql("data->'grantId'")).join(', ')
    else
      json_fragment.project.fundings.pluck(Arel.sql("data->'grantId'")).join(', ')
    end
  end

  def research_project?
    template.research_project?
  end

  def research_entity?
    template.research_entity?
  end

  def structured?
    template.structured?
  end

  private

  # Validation to prevent end date from coming before the start date
  def end_date_after_start_date
    # allow nil values
    return true if end_date.blank? || start_date.blank?

    errors.add(:end_date, _('must be after the start date')) if end_date < start_date
  end
end
