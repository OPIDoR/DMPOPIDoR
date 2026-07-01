# frozen_string_literal: true

# Controller for password resets that is built on the Devise gem
class PasswordsController < Devise::PasswordsController
  prepend_before_action :verify_altcha, only: [:create, :update]

  protected

  def verify_altcha
    return unless Rails.configuration.x.altcha.enabled

    unless Altcha.verify(params.permit(:altcha)[:altcha])
      flash[:alert] = _('Captcha verification failed, please retry.')
      if action_name == "update"
        redirect_to edit_password_path(
                      resource_name,
                      reset_password_token: params.dig(:user, :reset_password_token) || params[:reset_password_token]
                    )
      else
        redirect_to new_password_path(resource_name)
      end
      return
    end
  end

  def after_resetting_password_path_for(_resource)
    root_path
  end

  ##
  # Override Devise default behaviour by sending user to the home page
  # after the password reset email has been sent
  #
  # resource_name - The user's email address
  #
  # Returns String
  def after_sending_reset_password_instructions_path_for(_resource_name)
    root_path
  end
end
