# frozen_string_literal: true

module Types
  #  Classname
  class ClassnameEnum < Types::BaseEnum

    class_names = MadmpSchema.distinct.pluck(:classname).sort { |a, b| a <=> b }

    class_names.each do |value|
      value value.upcase
    end
  end
end
