# frozen_string_literal: true

# Controller that handles registries interrogation on the user's side
class RegistriesController < ApplicationController
  after_action :verify_authorized

  def index
    data_type = params[:data_type] || 'none'
    skip_authorization
    registries = Registry.where(Arel.sql("'#{data_type}' = ANY(data_types) AND category='#{params[:category]}'"))
    render json: registries.select(%w[id name])
  end

  def show
    registry = Registry.find(params[:id])

    skip_authorization
    render json: registry.values
  end

  def by_name
    registry = Registry.find_by(name: params[:name])

    skip_authorization
    render json: params[:page] ? registry.values.page(params[:page]) : registry.values
  end

  def suggest
    data_type = params[:data_type] || 'none'
    registry = Registry.find_by(Arel.sql("'#{data_type}' = ANY(data_types) AND category='#{params[:category]}'"))
    skip_authorization
    render json: {
      name: registry.name,
      values: registry.values
    }
  end

  # rubocop:disable Metrics/AbcSize
  def load_values
    registry = Registry.find(params[:id])
    plan = Plan.find(params[:plan_id])
    locale = plan.template.locale
    search_term = params[:term] || ''
    formatted_list = registry.values.select { |v| v.to_s(locale:).downcase.include?(search_term.downcase) }
                             .map { |v| { 'id' => select_value(v, locale), 'text' => v.to_s(locale:) } }
    authorize plan
    render json: {
      'results' => formatted_list
    }
  end
  # rubocop:enable Metrics/AbcSize
end
