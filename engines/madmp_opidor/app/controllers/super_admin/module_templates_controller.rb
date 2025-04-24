# frozen_string_literal: true

module SuperAdmin
  # Controller for creating and deleting Module Templates
  class ModuleTemplatesController < ApplicationController
    # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity
    def index
      authorize ::Template
      templates = ::Template.latest_module_version.where(customization_of: nil)
      published = templates.count { |t| t.published? || t.draft? }

      @orgs  = current_user.can_super_admin? ? Org.includes(:identifiers).all : nil
      @title = if current_user.can_super_admin?
                 format(_('%{org_name} Templates'), org_name: current_user.org.name)
               else
                 _('Own Templates')
               end
      @templates = templates.page(1)
      @query_params = { sort_field: 'templates.title', sort_direction: 'asc' }
      @all_count = templates.length
      @published_count = published.present? ? published : 0
      @unpublished_count = if published.present?
                             templates.length - published
                           else
                             templates.length
                           end
      render :index
    end
    # rubocop:enable Metrics/AbcSize, Metrics/PerceivedComplexity

    # Private instance methods
    private

    def permitted_params
      params.require(:template).permit(:title, :description, :visibility, :links, :locale, :type, :context, :data_type)
    end
  end
end
