# frozen_string_literal: true

module Static
  # Controller that handles requests for static pages
  class StaticPagesController < ApplicationController
    # before_action :set_static_page, only: :show

    prepend_view_path 'app/views/branded/static'

    # GET /static/:name
    def show
      @page = params[:name]
      render 'show'
    end
  end
end
