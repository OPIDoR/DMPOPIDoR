# frozen_string_literal: true

# Controller for the Contributors page
class ContributorsController < ApplicationController
  include OrgSelectable

  helper PaginableHelper

  before_action :fetch_plan
  after_action :verify_authorized

  def index
    authorize @plan
    @contributors = @plan.contributors
  end

  # =============
  # = Callbacks =
  # =============
  def fetch_plan
    @plan = Plan.find_by(id: params[:plan_id])
    return true if @plan.present?

    redirect_to root_path, alert: _('plan not found')
  end
end
