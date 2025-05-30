# frozen_string_literal: true

# == Schema Information
#
# Table name: madmp_schemas
#
#  id            :integer          not null, primary key
#  classname     :string
#  label         :string
#  name          :string
#  schema        :json
#  version       :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  api_client_id :bigint(8)
#  org_id        :integer
#
# Indexes
#
#  index_madmp_schemas_on_api_client_id  (api_client_id)
#  index_madmp_schemas_on_org_id         (org_id)
#
# Foreign Keys
#
#  fk_rails_...  (api_client_id => api_clients.id)
#  fk_rails_...  (org_id => orgs.id)
#

# Object that represents a madmp_schema
class MadmpSchema < ApplicationRecord
  include ValidationMessages

  belongs_to :org, required: false
  belongs_to :api_client, required: false
  has_many :madmp_fragments
  has_many :questions

  delegate :costs,
           :dmps,
           :funders,
           :metas,
           :partners,
           :persons,
           :projects,
           :research_outputs, to: :madmp_fragments

  validates :name, presence: { message: PRESENCE_MESSAGE },
                   uniqueness: { message: UNIQUENESS_MESSAGE }

  # validates :schema, presence:  { message: PRESENCE_MESSAGE },
  #                     json: true

  # ==========
  # = Constants =
  # ==========

  CLASSNAME_TO_PROPERTY = {
    'research_output_description' => 'researchOutputDescription',
    'data_reuse' => 'reuse',
    'personal_data_issues' => 'personalDataIssues',
    'legal_issues' => 'legalIssues',
    'ethical_issues' => 'ethicalIssues',
    'data_collection' => 'dataCollection',
    'data_processing' => 'dataProcessing',
    'data_storage' => 'dataStorage',
    'documentation_quality' => 'documentationQuality',
    'quality_assurance_method' => 'qualityAssuranceMethod',
    'data_sharing' => 'sharing',
    'data_preservation' => 'preservationIssues',
    'budget' => 'budget',
    # Software output
    'software_description' => 'softwareDescription',
    'software_development' => 'softwareDevelopment',
    'software_documentation' => 'softwareDocumentation',
    'software_runtime' => 'softwareRuntime',
    'software_preservation' => 'softwarePreservation',
    'software_legal_issues' => 'softwareLegalIssues',
    'software_sharing' => 'softwareSharing',
    'software_valorisation' => 'softwareValorisation'
  }.freeze

  # ==========
  # = Scopes =
  # ==========

  scope :search, lambda { |term|
    search_pattern = "%#{term}%"
    where('lower(madmp_schemas.name) LIKE lower(?) OR ' \
          'lower(madmp_schemas.classname) LIKE lower(?)',
          search_pattern, search_pattern)
  }

  scope :paginable, lambda {
    select(:id, :label, :name, :classname, :api_client_id, :version)
  }

  # =================
  # = Class Methods =
  # =================

  def detailed_name
    "#{label} ( #{name}_V#{version} )"
  end

  def description
    schema['description']
  end

  def properties
    schema['properties']
  end

  def defaults(locale)
    schema['default'].present? ? schema['default'][locale] : {}
  end

  def sub_schemas
    path = JsonPath.new('$..template_name')
    names = path.on(schema)
    MadmpSchema.where(name: names).to_h { |s| [s.id, s] }
  end

  def sub_schemas_ids
    path = JsonPath.new('$..template_name')
    path.on(schema)
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def generate_strong_params(flat: false)
    parameters = []
    properties.each do |key, prop|
      if prop['type'] == 'object' && prop['template_name'].present?
        if prop['inputType'].eql?('pickOrCreate')
          parameters.append(key)
        elsif prop['registry_id'].present?
          parameters.append(key)
          parameters.append("#{key}_custom") if prop['overridable'].present?
        else
          sub_schema = MadmpSchema.find_by(name: prop['template_name'])
          parameters.append(key => sub_schema.generate_strong_params(flat: false))
        end
      elsif prop['type'].eql?('array') && !flat
        parameters.append(key => [])
      else
        parameters.append(key)
        parameters.append("#{key}_custom") if prop['overridable'].present?
      end
    end
    parameters
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  # rubocop:enable Metrics/AbcSize

  # Used by "Write Plan" tab for determining the property_name of a new fragment
  # from the classname of the corresponding schema
  def property_name_from_classname
    CLASSNAME_TO_PROPERTY[classname]
  end

  def extract_run_parameters(script_name: nil)
    return {} if schema['run'].nil?
    return schema['run'] if script_name.nil?

    schema['run'].find { |run| run['name'] == script_name } || {}
  end

  def run_parameters?
    return false if schema['run'].nil?

    true
  end

  def const_data(locale)
    const_data = {}
    properties.each do |key, prop|
      next if prop["const@#{locale}"].nil?

      const_data[key] = prop["const@#{locale}"]
    end
    const_data
  end

  def self.serialize_json_response(schema)
    {
      id: schema.id,
      name: schema.name,
      schema: schema.schema,
      api_client: if schema.api_client.present?
                    {
                      id: schema.api_client_id,
                      name: schema.api_client.name
                    }
                  end
    }
  end
end
