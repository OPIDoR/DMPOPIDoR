# frozen_string_literal: true

# Templates controller specific to DMP OPIDoR, allows the app to get JSON info about a DMP template
class TemplatesController < ApplicationController
  after_action :verify_authorized

  def show
    template = Template.includes(
      { sections: :questions }
    ).find(params[:id])

    authorize template, policy_class: PublicTemplateInfoPolicy

    render json: template.serialize_json
  end

  def set_recommended
    template = Template.find(params[:template_id])

    authorize template, policy_class: PublicTemplateInfoPolicy
    template.is_recommended = params[:is_recommended] == '1'

    if template.save
      render json: {
        code: 1,
        msg: (
          if template.is_recommended?
            _("'#{template.title}' template is now recommended.")
          else
            _("'#{template.title}' template is no longer recommended.")
          end
        )
      }
    else
      render status: :bad_request, json: {
        code: 0, msg: _("Unable to change the template's recommended status")
      }
    end
  end
end
