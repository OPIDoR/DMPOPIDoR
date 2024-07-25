module Types
  class LanguageFilterInputType < Types::BaseInputObject
    argument :abbreviation, String, required: false
  end
end