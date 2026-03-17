# == Schema Information
#
# Table name: registries
#
#  id          :integer          not null, primary key
#  category    :string
#  data_types  :string           default(["dataset"]), not null, is an Array
#  description :string
#  name        :string           not null
#  topics      :string           default(["generic"]), not null, is an Array
#  uri         :string
#  values      :json
#  version     :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  org_id      :integer
#
# Indexes
#
#  index_registries_on_org_id  (org_id)
#
# Foreign Keys
#
#  fk_rails_...  (org_id => orgs.id)
#
FactoryBot.define do
  factory :registry do
    name                    { Faker::Lorem.unique.word }
    description             { Faker::Lorem.sentence }
    uri                     { Faker::Internet.unique.url }
    category                { Faker::Lorem.unique.word }
    values                  { [] }
    topics                  { ['generic'] }
    data_types              { ['none'] }
    version                 { 1 }
  end
end
