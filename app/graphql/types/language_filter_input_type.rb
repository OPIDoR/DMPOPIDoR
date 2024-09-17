module Types
  class LanguageFilterInputType < Types::BaseInputObject
    argument :abbreviation, String, required: false
    argument :name, String, required: false
  end
end