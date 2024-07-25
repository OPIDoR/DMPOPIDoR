module Resolvers
  class LanguageResolver < BaseResolver
    type Types::LanguageType, null: false
    argument :id, ID

    def resolve(id:)
      Language.find_by(id: id)
    end
  end
end