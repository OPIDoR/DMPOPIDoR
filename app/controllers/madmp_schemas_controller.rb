# frozen_string_literal: true

# Controller for the MadmpSchemas, handle structures forms
class MadmpSchemasController < ApplicationController
  after_action :verify_authorized

  # rubocop:disable Metrics/AbcSize
  def index
    data_type = params[:data_type] || 'none'
    topics = [params[:topic], 'generic'].compact.uniq
    authorize(MadmpSchema)
    condition = Arel.sql("topics && ARRAY[#{topics.map { |t| "'#{t}'" }.join(',')}]::varchar[]")
    render json: MadmpSchema.where(condition).where(data_type: data_type, classname: params[:classname])
                 .map do |schema|
                   MadmpSchema.serialize_json_response(schema)
                 end
  end
  # rubocop:enable Metrics/AbcSize

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
