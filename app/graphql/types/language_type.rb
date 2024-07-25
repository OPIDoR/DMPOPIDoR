module Types
  class LanguageType < Types::BaseObject
    field :id, ID, null: false
    field :abbreviation, String, null: false
  end
end
