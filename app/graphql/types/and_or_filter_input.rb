# frozen_string_literal: true

module Types
  # AndFilterInput
  module AndOrFilterInput
    class AndFilterInput < Types::BaseInputObject
      instance_eval(&Types::SharedFields::shared_and_or_filter(level: 1))
    end

    class OrFilterInput < Types::BaseInputObject
      instance_eval(&Types::SharedFields::shared_and_or_filter(level: 1))
    end

    class AndSubFilterInput < Types::BaseInputObject
      instance_eval(&Types::SharedFields::shared_and_or_filter(level: nil))
    end

    class OrSubFilterInput < Types::BaseInputObject
      instance_eval(&Types::SharedFields::shared_and_or_filter(level: nil))
    end
  end
end
