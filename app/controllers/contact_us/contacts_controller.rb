# frozen_string_literal: true

module ContactUs
  # Controller for the Contact Us gem
  class ContactsController < ApplicationController
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def create
      @contact = ContactUs::Contact.new(params[:contact_us_contact])

      if !user_signed_in? && Rails.configuration.x.recaptcha.enabled &&
         !(verify_recaptcha(action: 'contact_us', model: @contact) && @contact.save)
        flash[:alert] = _('Captcha verification failed, please retry.')
        @show_checkbox_recaptcha = true
        render_new_page and return
      end
      if @contact.save
        return redirect_to(ContactUs.success_redirect || contact_us_path,
                    notice: _('Contact email was successfully sent.'))
      else
        flash[:alert] = _('Unable to submit your request')
        render_new_page and return
      end
    rescue Net::SMTPFatalError => e
      Rails.logger.error("SMTP Error: #{e.message}")
      flash[:alert] = _('An unexpected error occurred while sending the email. Please try again later.')
      render_new_page and return
    rescue StandardError => e
      Rails.logger.error("Mailer Error: #{e.message}")
      flash[:alert] = _('An unexpected error occurred while sending the email. Please try again later.')
      render_new_page and return
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    def new
      @contact = ContactUs::Contact.new
      render_new_page
    end

    protected

    def render_new_page
      case ContactUs.form_gem
      when 'formtastic'  then render 'new_formtastic', locals: { contact: @contact }
      when 'simple_form' then render 'new_simple_form', locals: { contact: @contact }
      else
        render 'new', locals: { contact: @contact }
      end
    end
  end
end
