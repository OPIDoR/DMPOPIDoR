module Types
  class QueryType < Types::BaseObject
    field :languages, resolver: Resolvers::LanguagesResolver, description: "Fetch languages"
    field :language, Types::LanguageType, resolver: Resolvers::LanguageResolver, null: false, description: "Fetch language by id"
  end
end