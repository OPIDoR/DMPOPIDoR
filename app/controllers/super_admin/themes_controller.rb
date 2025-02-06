# frozen_string_literal: true

module SuperAdmin
  # Controller for managing Themes
  class ThemesController < ApplicationController
    helper PaginableHelper
    def index
      authorize(Theme)
      @locales = Language.all
      render(:index, locals: { themes: Theme.all.order(:number).page(1) })
    end

    def new
      authorize(Theme)
      @locales = Language.where.not(abbreviation: 'fr-FR')
      @theme = Theme.new
    end

    # rubocop:disable Metrics/AbcSize
    def create
      authorize(Theme)
      @theme = Theme.new(permitted_params)
      @locales = Language.where.not(abbreviation: 'fr-FR')
      if @theme.save
        flash.now[:notice] = success_message(@theme, _('created'))
        render :edit
      else
        flash.now[:alert] = failure_message(@theme, _('create'))
        render :new
      end
    end
    # rubocop:enable Metrics/AbcSize

    def edit
      authorize(Theme)
      @locales = Language.where.not(abbreviation: 'fr-FR')
      @theme = Theme.find(params[:id])
    end

    # rubocop:disable Metrics/AbcSize
    def update
      authorize(Theme)
      @theme = Theme.find(params[:id])
      @locales = Language.where.not(abbreviation: 'fr-FR')

      if @theme.update(permitted_params)
        flash.now[:notice] = success_message(@theme, _('updated'))
      else
        flash.now[:alert] = failure_message(@theme, _('update'))
      end
      render :edit
    end
    # rubocop:enable Metrics/AbcSize

    def destroy
      authorize(Theme)
      @theme = Theme.find(params[:id])
      if @theme.destroy
        msg = success_message(@theme, _('deleted'))
        redirect_to super_admin_themes_path, notice: msg
      else
        flash.now[:alert] = failure_message(@theme, _('delete'))
        render :edit
      end
    end

    def sort
      authorize(Theme)
      params[:updated_order].each_with_index do |id, index|
        ::Theme.find(id).update(number: index + 1)
      end
      head :ok
    end

    # Private instance methods

    private

    def permitted_params
      permitted = params.require(:theme).permit(
        :title,
        :description,
        :data_type,
        translations: {}
      )

      permitted[:translations]&.each do |locale, translation|
        permitted[:translations].delete(locale) if translation['title'].blank?
      end

      permitted
    end
  end
end
