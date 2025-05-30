# frozen_string_literal: true

# Controller for the MadmpSchemas, handle structures forms
class MadmpSchemasController < ApplicationController
  after_action :verify_authorized

  def index
    data_type = params[:data_type] || 'none'
    authorize(MadmpSchema)
    render json: MadmpSchema.where(classname: params[:classname], data_type:).select(%w[id name label schema])
  end

  def show
    authorize(MadmpSchema)
    @schema = MadmpSchema.find(params[:id])
    render json: MadmpSchema.serialize_json_response(@schema)
  end

  def by_name
    authorize(MadmpSchema)
    @schema = MadmpSchema.find_by(name: params[:name])

    if @schema.present?
      render json: MadmpSchema.serialize_json_response(@schema)
    else
      render status: :not_found,
             json: { message: _(format('%{template_name} form is unavailable.', template_name: params[:name])) }
    end
  end
end
