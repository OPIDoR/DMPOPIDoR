# frozen_string_literal: true

module Paginable
  # Controller for paginating/sorting/searching the users table
  class UsersController < ApplicationController
    prepend Dmpopidor::Paginable::UsersController
    include Paginable

    # --------------------------------
    # Start DMP OPIDoR Customization
    # SEE app/controllers/dmpopidor/paginable/users_controller.rb
    # Changes : Users without activity should not be displayed first
    # --------------------------------
    # /paginable/users/index/:page
    # rubocop:disable Metrics/AbcSize
    def index
      authorize User
      @clicked_through = params[:click_through].present?

      # variable containing the check box value
      @filter_admin = params[:filter_admin] == '1'

      scope = if current_user.can_super_admin?
                User.includes(:department, :org, :perms, :roles, :identifiers)
              else
                current_user.org.users.includes(:department, :org, :perms, :roles, :identifiers)
              end

      scope = scope.joins(:perms).distinct if @filter_admin

      paginable_renderise(
        partial: 'index',
        scope: scope,
        query_params: { sort_field: 'users.surname', sort_direction: :asc },
        format: :json,
        view_all: !current_user.can_super_admin?
      )
    end
    # rubocop:enable Metrics/AbcSize
    # --------------------------------
    # End DMP OPIDoR Customization
    # --------------------------------
  end
end
