# frozen_string_literal: true

# Controller that handles registries interrogation on the user's side
class RegistriesController < ApplicationController
  after_action :verify_authorized

  # rubocop:disable Metrics/AbcSize
  def index
    data_type = params[:data_type] || 'dataset'
    topic = params[:topic] || 'generic'
    skip_authorization
    registries = Registry.where(Arel.sql("'#{data_type}' = ANY(data_types) AND category='#{params[:category]}'"))
    registries = if registries.where(Arel.sql("'#{topic}' = ANY(topics)")).exists?
                   registries.where(Arel.sql("'#{topic}' = ANY(topics)"))
                 else
                   registries.where(Arel.sql("'generic' = ANY(topics)"))
                 end
    render json: registries.length > 1 ? registries.select(%w[id name]) : registries.select(%w[id name values])
  end
  # rubocop:enable Metrics/AbcSize

  def show
    registry = Registry.find(params[:id])
    skip_authorization
    render json: registry.present? ? registry.values : []
  end

  def by_name
    registry = Registry.find_by(name: params[:name])
    values = registry.present? ? registry.values : []
    skip_authorization
    render json: params[:page] ? values.page(params[:page]) : values
  end

  def suggest
    data_type = params[:data_type] || 'dataset'
    registry = Registry.find_by(Arel.sql("'#{data_type}' = ANY(data_types) AND category='#{params[:category]}'"))
    skip_authorization
    render json: {
      name: registry.name,
      values: registry.values
    }
  end
end
