# frozen_string_literal: true

module OrgAdmin
  # Controller that handles themes rendering
  class ThemesController < ApplicationController
    def index
      render json: {
        themes: Theme.all.order('title').map do |theme|
          { id: theme.id, title: theme.title }
        end
      }
    end
  end
end
