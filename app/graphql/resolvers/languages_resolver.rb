module Resolvers
  class LanguagesResolver < BaseResolver
    type [Types::LanguageType], null: false
    argument :filter, Types::LanguageFilterInputType, required: false

    def resolve(filter: nil)
      languages = Language.all
      if filter.present?
        if filter.abbreviation.present?
          languages = languages.where(abbreviation: filter.abbreviation)
        end
        if filter.name.present?
          languages = languages.where(name: filter.name)
        end
      end
      languages
    end
  end
end