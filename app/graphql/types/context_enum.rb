# frozen_string_literal: true

module Types
  #  ContextEnum
  class ContextEnum < Types::BaseEnum
    %w[research_project research_entity].each do |value|
      value value.upcase
    end
  end
end
