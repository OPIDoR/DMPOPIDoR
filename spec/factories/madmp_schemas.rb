# frozen_string_literal: true

# == Schema Information
#
# Table name: madmp_schemas
#
#  id            :integer          not null, primary key
#  classname     :string
#  data_type     :string           default("dataset"), not null
#  label         :string
#  name          :string
#  schema        :json
#  topics        :string           default(["generic"]), not null, is an Array
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
FactoryBot.define do
  factory :madmp_schema do
    name { Faker::Lorem.sentence }
    data_type { 'none' }
    topics { ['generic'] }
    schema { {} }

    trait :dmp do
      classname { 'dmp' }
      schema { MadmpSchema.find_by(name: 'DmpStandard').schema }
    end

    trait :research_output do
      classname { 'research_output' }
      schema { MadmpSchema.find_by(name: 'ResearchOutputStandard').schema }
    end
  end
end
