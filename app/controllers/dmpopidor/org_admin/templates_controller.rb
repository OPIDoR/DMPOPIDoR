# frozen_string_literal: true

module Dmpopidor
  module OrgAdmin
    # Customized code for OrgAdmin QuestionsController
    module TemplatesController
      # A version of index that displays only module templates
      # GET /org_admin/templates/modules
      # -----------------------------------------------------
      # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity
      def modules
        authorize ::Template
        templates = ::Template.latest_module_version.where(customization_of: nil)
        published = templates.count { |t| t.published? || t.draft? }

        @orgs  = current_user.can_super_admin? ? ::Org.includes(:identifiers).all : nil
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
    end
  end
end
