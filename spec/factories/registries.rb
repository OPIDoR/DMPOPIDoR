FactoryBot.define do
  factory :registry do
    name                    { Faker::Lorem.unique.word }
    description             { Faker::Lorem.sentence }
    uri                     { Faker::Internet.unique.url }
    category                { Faker::Lorem.unique.word }
    values                  { [] }
    topics                  { ['standard'] }
    data_types              { ['none'] }
    version                 { 1 }
  end
end
