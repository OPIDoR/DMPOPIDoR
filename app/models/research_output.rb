# frozen_string_literal: true

# == Schema Information
#
# Table name: research_outputs
#
#  id                      :integer          not null, primary key
#  abbreviation            :string
#  access                  :integer          default("open"), not null
#  byte_size               :bigint(8)
#  description             :text
#  display_order           :integer
#  is_default              :boolean          default(FALSE)
#  output_type             :integer          default("dataset"), not null
#  output_type_description :string
#  personal_data           :boolean
#  pid                     :string
#  release_date            :datetime
#  sensitive_data          :boolean
#  title                   :string
#  uuid                    :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  license_id              :bigint(8)
#  plan_id                 :integer
#
# Indexes
#
#  index_research_outputs_on_license_id  (license_id)
#  index_research_outputs_on_plan_id     (plan_id)
#
# Foreign Keys
#
#  fk_rails_...  (license_id => licenses.id)
#  fk_rails_...  (plan_id => plans.id)
#

# Object that represents a proposed output for a project
class ResearchOutput < ApplicationRecord
  include Identifiable
  include ValidationMessages

  # --------------------------------
  # Start DMP OPIDoR Customization
  # --------------------------------
  extend UniqueRandom

  attribute :uuid, :string, default: -> { unique_uuid(field_name: 'uuid') }

  prepend Dmpopidor::ResearchOutput
  after_destroy :destroy_json_fragment
  # --------------------------------
  # End DMP OPIDoR Customization
  # --------------------------------

  enum :output_type, %i[audiovisual collection data_paper dataset event image
                        interactive_resource model_representation physical_object
                        service software sound text workflow other]

  enum :access, %i[open embargoed restricted closed]

  # ================
  # = Associations =
  # ================

  belongs_to :plan, optional: true, touch: true
  belongs_to :license, optional: true

  has_and_belongs_to_many :metadata_standards
  has_and_belongs_to_many :repositories

  has_many :answers, dependent: :destroy

  # ===============
  # = Validations =
  # ===============

  validates_presence_of :output_type, :access, :title, message: PRESENCE_MESSAGE
  validates_uniqueness_of :title, { case_sensitive: false, scope: :plan_id,
                                    message: UNIQUENESS_MESSAGE }
  validates_uniqueness_of :abbreviation, { case_sensitive: false, scope: :plan_id,
                                           allow_nil: true, allow_blank: true,
                                           message: UNIQUENESS_MESSAGE }

  validates_numericality_of :byte_size, greater_than: 0, less_than_or_equal_to: 2**63,
                                        allow_blank: true,
                                        message: '(Anticipated file size) is too large. Please enter a smaller value.'
  # Ensure presence of the :output_type_description if the user selected 'other'
  validates_presence_of :output_type_description, if: -> { other? }, message: PRESENCE_MESSAGE

  validates :abbreviation, presence: { message: PRESENCE_MESSAGE }

  validates :plan, presence: { message: PRESENCE_MESSAGE }

  # ==========
  # = Scopes =
  # ==========

  default_scope { order(display_order: :asc) }

  # ====================
  # = Instance methods =
  # ====================

  # Helper method to convert selected repository form params into Repository objects
  def repositories_attributes=(params)
    params.each_value do |repository_params|
      repositories << Repository.find_by(id: repository_params[:id])
    end
  end

  # Helper method to convert selected metadata standard form params into MetadataStandard objects
  def metadata_standards_attributes=(params)
    params.each_value do |metadata_standard_params|
      metadata_standards << MetadataStandard.find_by(id: metadata_standard_params[:id])
    end
  end

  ##
  # deep copy the given research output
  #
  # Returns Research output
  def self.deep_copy(research_output)
    research_output.dup
  end

  #####
  # Returns an array containing the property name, description question & the madmpschema according to the
  # data_type in parameters
  #####
  def self.data_type_to_schema_data(plan, data_type, locale)
    if data_type.eql?('software') && MadmpSchema.exists?(name: 'SoftwareDescriptionStandard')
      [
        'softwareDescription',
        Template.module(data_type:, locale:).questions.joins(:madmp_schema).find_by(madmp_schemas: { classname: 'software_description' }), # rubocop:disable Layout/LineLength
        MadmpSchema.find_by(name: 'SoftwareDescriptionStandard')
      ]
    else
      [
        'researchOutputDescription',
        plan.questions.joins(:madmp_schema).find_by(madmp_schemas: { classname: 'research_output_description' }),
        MadmpSchema.find_by(name: 'ResearchOutputDescriptionStandard')
      ]
    end
  end

  private

  #####
  # Returns an array containing the researchOutput fragment additional info and researchOutput description data
  # depending on the research output configuration in parameters
  #####
  # rubocop:disable Metrics/MethodLength
  def configuration_to_additional_info_data(configuration, locale)
    case configuration[:dataType]
    when 'software'
      [
        {
          property_name: 'researchOutput',
          dataType: configuration[:dataType],
          moduleId: ::Template.module(data_type: configuration[:dataType], locale:)&.id
        },
        {
          'title' => title,
          'shortName' => abbreviation,
          'type' => output_type_description
        }
      ]
    else
      [
        {
          property_name: 'researchOutput',
          hasPersonalData: configuration[:hasPersonalData] || false,
          dataType: 'none'
        },
        {
          'title' => title,
          'shortName' => abbreviation,
          'type' => output_type_description,
          'containsPersonalData' => configuration[:hasPersonalData] ? _('Yes') : _('No')
        }
      ]
    end
  end
  # rubocop:enable Metrics/MethodLength
end
