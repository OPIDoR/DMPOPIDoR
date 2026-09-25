# frozen_string_literal: true

module Types
  # AndFilterInput
  module AndOrFilterInput
    # AndFilterInput and OrFilterInput are used to build complex logical filters for GraphQL queries.
    class AndFilterInput < Types::BaseInputObject
      instance_eval(&Types::SharedFields.shared_and_or_filter)
    end

    # AndFilterInput and OrFilterInput are used to build complex logical filters for GraphQL queries.
    class OrFilterInput < Types::BaseInputObject
      instance_eval(&Types::SharedFields.shared_and_or_filter)
    end
  end
end
