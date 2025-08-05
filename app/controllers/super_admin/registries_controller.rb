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

    def create
      authorize(Registry)
      attrs = permitted_params
      @registry = Registry.new(attrs.except(:values))
      if @registry.save
        Registry.load_values(attrs[:values], @registry)
        redirect_to edit_super_admin_registry_path(@registry), notice: success_message(@registry, _('created'))
      else
        redirect_to edit_super_admin_registry_path(@registry), alert: success_message(@registry, _('create'))
      end
    end

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

    def sort_values
      @registry = Registry.find(params[:id])
      authorize @registry
      params[:updated_order].each_with_index do |id, index|
        RegistryValue.find(id).update!(order: index + 1)
      end
      head :ok
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
