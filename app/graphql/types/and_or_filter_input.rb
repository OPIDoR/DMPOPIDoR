# frozen_string_literal: true

module Types
  # AndFilterInput
  module AndOrFilterInput
    class AndFilterInput < Types::BaseInputObject
      instance_eval(&Types::SharedFields::shared_and_or_filter)
    end

    class OrFilterInput < Types::BaseInputObject
      instance_eval(&Types::SharedFields::shared_and_or_filter)
    end
  end
end
