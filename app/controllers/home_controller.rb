# frozen_string_literal: true

# Controller for the home page that users see when not logged in
class HomeController < ApplicationController
  include OrgSelectable

  respond_to :html

  def index; end

  def login
    return unless Rails.configuration.x.oidc.enabled

    redirect_to user_oidc_omniauth_authorize_path
  end
end
