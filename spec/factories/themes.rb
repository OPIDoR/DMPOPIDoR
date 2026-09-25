# frozen_string_literal: true

# == Schema Information
#
# Table name: themes
#
#  id           :integer          not null, primary key
#  data_type    :string           default("dataset"), not null
#  description  :text
#  number       :integer
#  slug         :string
#  title        :string
#  translations :json
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

FactoryBot.define do
  factory :theme do
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    translations { {} }
  end
end
