# frozen_string_literal: true

module Types
  #  Classname
  class ClassnameEnum < Types::BaseEnum

    class_names = MadmpSchema.distinct.pluck(:classname)

    class_names.each do |value|
      value value.upcase
    end
  end
end
