module Types
  class LanguageType < Types::BaseObject
    field :id, ID, null: false
    field :abbreviation, String, null: false
    field :name, String, null: false
    field :default_language, String, null: true
  end
end
