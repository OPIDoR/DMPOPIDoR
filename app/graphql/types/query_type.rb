module Types
  class QueryType < Types::BaseObject
    field :languages, resolver: Resolvers::LanguagesResolver, description: "Fetch languages"
    field :language, Types::LanguageType, resolver: Resolvers::LanguageResolver, description: "Fetch language by id"
    field :plans, resolver: Resolvers::PlansResolver, description: "Fetch plans"
  end
end