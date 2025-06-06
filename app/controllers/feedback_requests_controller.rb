# frozen_string_literal: true

# Controller that handles requests for Admin Feedback
class FeedbackRequestsController < ApplicationController
  include FeedbacksHelper

  after_action :verify_authorized

  ALERT = _('Unable to submit your request for feedback at this time.')
  ERROR = _('An error occurred when requesting feedback for this plan.')

  def create
    @plan = Plan.find(params[:plan_id])
    authorize @plan, :request_feedback?
    begin
      if @plan.request_feedback(current_user)
        # --------------------------------
        # Start DMP OPIDoR Customization
        # CHANGES: Changed feedback request message
        # --------------------------------
        redirect_to request_feedback_plan_path(@plan), notice: _('Feedback has been requested.')
        # --------------------------------
        # End DMP OPIDoR Customization
        # --------------------------------
      else
        redirect_to request_feedback_plan_path(@plan), alert: ALERT
      end
    rescue StandardError
      redirect_to request_feedback_plan_path(@plan), alert: ERROR
    end
  end

  private

  # Flash notice for successful feedback requests
  #
  # Returns String
  def request_feedback_flash_notice
    # Use the generic feedback confirmation message unless the Org has
    # specified one
    text = current_user.org.feedback_msg || feedback_confirmation_default_message
    feedback_constant_to_text(text, current_user, @plan, current_user.org)
  end
end
