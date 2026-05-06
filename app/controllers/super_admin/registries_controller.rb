# frozen_string_literal: true

require 'json'
module SuperAdmin
  # Controller for creating and deleting Registries
  class RegistriesController < ApplicationController
    # GET /madmp_schemas
    def index
      authorize(Registry)
      render(:index, locals: { registries: Registry.all.page(1) })
    end

    def new
      authorize(Registry)
      @registry = Registry.new
      @topics = Registry.find_by(name: 'Topics')&.values || []
    end

    # rubocop:disable Metrics/AbcSize
    def create
      authorize(Registry)
      attrs = permitted_params
      @registry = Registry.new(attrs.except(:values))

      if @registry.save
        result = Registry.load_values(attrs[:values], @registry)

        case result
        when :success
          flash[:notice] = success_message(@registry, _('created'))
        when :wrong_format
          flash[:alert] = _('Wrong values file format')
        when :invalid_json
          flash[:alert] = _('File should contain JSON')
        when :bad_file
          flash[:alert] = _('Unrecognized file input')
        end

        redirect_to edit_super_admin_registry_path(@registry)
      else
        redirect_to edit_super_admin_registry_path(@registry), alert: success_message(@registry, _('create'))
      end
    end
    # rubocop:enable Metrics/AbcSize

    def edit
      authorize(Registry)
      @registry = Registry.find(params[:id])
      @topics = Registry.find_by(name: 'Topics')&.values || []
    end

    # rubocop:disable Metrics/AbcSize
    def update
      authorize(Registry)
      attrs = permitted_params
      @registry = Registry.find(params[:id])
      if @registry.update(attrs.except(:values))
        Registry.load_values(attrs[:values], @registry)
        redirect_to edit_super_admin_registry_path(@registry), notice: success_message(@registry, _('updated'))
      else
        redirect_to edit_super_admin_registry_path(@registry), alert: failure_message(@registry, _('update'))
      end
    end
    # rubocop:enable Metrics/AbcSize

    def destroy
      authorize(Registry)
      @registry = Registry.find(params[:id])
      if @registry.destroy
        redirect_to super_admin_registries_path, notice: success_message(@registry, _('deleted'))
      else
        redirect_to edit_super_admin_registry_path(@registry), alert: failure_message(@registry, _('delete'))
      end
    end

    def download
      registry = Registry.find(params[:registry_id])
      authorize registry
      data = { registry.name => registry.values }
      send_data(JSON.pretty_generate(data), filename: "#{registry.name}.json")
    end

    def upload
      registry = Registry.find(params[:registry_id])
      authorize registry
    end

    # Private instance methods
    private

    def permitted_params
      params.require(:registry).permit(:name, :description, :uri, :category, :version, :values, data_types: [],
                                                                                                topics: [])
    end
  end
end
