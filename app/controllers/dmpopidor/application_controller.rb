# frozen_string_literal: true

require 'httparty'

module Dmpopidor
  # Customized code for ApplicationController
  module ApplicationController
    # Set Static Pages collection to use in navigation
    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def set_nav_static_pages
      @nav_static_pages = []

      query = '
        query {
          static_pages(filter: { status: { _eq: "published" } }) {
            path,
            inMenu,
            translations {
              languages_code {
                code
              }
              title
            }
          }
        }
      '

      begin
        resp = HTTParty.post("#{Rails.configuration.x.directus.url}/graphql",
                             body: { query: query }.to_json,
                             headers: { 'Content-Type' => 'application/json' })
      rescue StandardError
        return @nav_static_pages
      end

      return @nav_static_pages unless resp.present? && resp.code == 200

      resp = JSON.parse(resp.body)

      pages = resp['data']['static_pages']&.map do |page|
        page_translation = page['translations']
        {
          'path' => page['path'],
          'inMenu' => page['inMenu'],
          'title' => reduce_translations(page_translation, 'title')
        }
      end

      return @nav_static_pages if pages.nil?

      @nav_static_pages = pages
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    # Added Research output Support
    # rubocop:disable Metrics/AbcSize
    def obj_name_for_display(obj)
      display_name = {
        ApiClient: _('API client'),
        ResearchOutput: _('research output'),
        ExportedPlan: _('plan'),
        GuidanceGroup: _('guidance group'),
        Note: _('comment'),
        Org: _('organisation'),
        Perm: _('permission'),
        Pref: _('preferences'),
        Department: _('department'),
        User: obj == current_user ? _('profile') : _('user'),
        QuestionOption: _('question option'),
        MadmpSchema: _('schema'),
        Registry: _('registry'),
        RegistryValue: _('registry value')
      }
      if obj.respond_to?(:customization_of) && obj.send(:customization_of).present?
        display_name[:Template] = 'customization'
      end
      display_name[obj.class.name.to_sym] || obj.class.name.downcase || 'record'
    end
    # rubocop:enable Metrics/AbcSize

    def after_sign_in_path_for(_resource)
      plans_path(anchor: 'content')
    end

    private

    def reduce_translations(translations, field)
      translations.reduce({}) do |result, translation|
        result.merge(
          translation['languages_code']['code'] => translation[field]
        )
      end
    end
  end
end
