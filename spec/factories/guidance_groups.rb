# frozen_string_literal: true

# == Schema Information
#
# Table name: guidance_groups
#
#  id          :integer          not null, primary key
#  data_types  :string           default(["dataset"]), not null, is an Array
#  description :string
#  is_default  :boolean          default(FALSE), not null
#  name        :string
#  published   :boolean          default(FALSE), not null
#  topics      :string           default(["generic"]), not null, is an Array
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  language_id :integer          default(0)
#  org_id      :integer
#
# Indexes
#
#  guidance_groups_org_id_idx  (org_id)
#
# Foreign Keys
#
#  fk_rails_...  (org_id => orgs.id)
#

FactoryBot.define do
  factory :guidance_group do
    name { Faker::Lorem.unique.word }
    org
    language { Language.default }
    published { true }
    trait :unpublished do
      published { false }
    end
  end
end
