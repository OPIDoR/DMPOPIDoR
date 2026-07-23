# frozen_string_literal: true

module OrgAdmin
  # Controller that handles themes rendering
  class ThemesController < ApplicationController
    def index
      locale = params[:locale]
      data_types = params[:data_types]&.split(',') || 'dataset'
      render json: {
        themes: Theme.where(data_type: data_types).order('title').map do |theme|
          { id: theme.id, title: theme&.translations&.[](locale)&.fetch('title', nil) || theme&.title }
        end
      }
    end
  end
end
