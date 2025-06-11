# frozen_string_literal: true

module Types
  #  FormatEnum
  class FormatEnum < Types::BaseEnum
    %w[standard rda].each do |value|
      value value.upcase
    end
  end
end
