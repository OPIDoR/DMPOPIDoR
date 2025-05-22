# frozen_string_literal: true

module Types
  #  LocaleEnum
  class LocaleEnum < Types::BaseEnum

    locales = Language.all.map do |locale|
      locale.abbreviation.split('-').first
    end.uniq

    locales.each do |value|
      value value.upcase
    end
  end
end
