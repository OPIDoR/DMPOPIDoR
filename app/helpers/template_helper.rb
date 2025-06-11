# frozen_string_literal: true

# Helper methods for Templates
module TemplateHelper
  def template_details_path(template)
    if template_modifiable?(template)
      template&.module? ? edit_super_admin_template_path(template) : edit_org_admin_template_path(template)
    elsif template.persisted?
      if template&.module?
        super_admin_template_path(template)
      else
        org_admin_template_path(template)
      end
    elsif template&.module?
      super_admin_templates_path
    else
      org_admin_templates_path
    end
  end

  # Is this Template modifiable?
  #
  # template - A Template object
  #
  # Returns Boolean
  def template_modifiable?(template)
    template.latest? &&
      template.customization_of.blank? &&
      template.id.present? &&
      template.org_id = current_user.org.id
  end

  def links_to_a_elements(links, separator = ', ')
    a = links.map do |l|
      "<a href=\"#{l['link']}\">#{l['text']}</a>"
    end
    a.join(separator)
  end

  # Generate a direct plan creation link based on provided template
  # @param template [Template] template used for plan creation
  # @param hidden [Boolean] should the link be hidden?
  # @param text [String] text for the link
  # @param id [String] id for the link element
  # rubocop:disable Style/OptionalBooleanParameter
  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def direct_link(template, hidden = false, text = nil, id = nil)
    params = {
      org: { id: "{ \"id\": #{current_user&.org&.id}, \"name\": \"#{current_user&.org&.name}\" }" },
      funder: { id: "{ \"id\": #{template.org&.id}, \"name\": \"#{template.org&.name}\" }" },
      template_id: template.id
    }
    cls = text.nil? ? 'direct-link' : 'direct-link btn btn-secondary'
    style = hidden ? 'display: none' : ''

    link_to(plans_url(plan: params), data: { turbo_method: :post }, title: _('Create plan'),
                                     class: cls, id: id, style: style) do
      if text.nil?
        '<span class="fas fa-square-plus"></span>'.html_safe
      else
        text.html_safe
      end
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  # rubocop:enable Style/OptionalBooleanParameter

  # Method that determines if an admin can add a phase to a template
  # Returns true for classic templates
  # Returns true for structured & module templates if there is no phase
  def can_add_phase?(template)
    return true if template.classic?

    true if template.phases.empty?
  end
end
