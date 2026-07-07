# frozen_string_literal: true

# Controller that handles a user disassociating their Shib or ORCID on the profile page
class LanguagesController < ApplicationController
  respond_to :json

  def index
    @languages = Language.all
    render json: @languages.map { |language|
      { id: language.id, abbreviation: language.abbreviation.tr!('-', '_'), name: language.name }
    }
  end
end
