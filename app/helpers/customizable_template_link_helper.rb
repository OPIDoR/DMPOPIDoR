# frozen_string_literal: true

# Helper methods for generating links for customizing templates
module CustomizableTemplateLinkHelper
  # Link to the appropriate customizable template.
  # Default link name set if name not set which can be overwritten.
  # rubocop:disable-next Metrics/AbcSize, Metrics/PerceivedComplexity
  # rubocop:disable-next Metrics/CyclomaticComplexity
  def link_to_customizable_template(name, customization, template, dropdown)
    name = nil unless name.present?
    link_css = dropdown ? 'dropdown-item px-3' : 'px-3'

    if customization.present?

      if customization.created_at < template.created_at
        name = _('Transfer customisation') if name.blank?
        link_to name,
                org_admin_template_customization_transfers_path(customization.id),
                data: { turbo_method: 'post', turbo_frame: '_top' },
                class: link_css
      else
        name = _('Edit customisation') if name.blank?
        link_to name, org_admin_template_path(id: customization.id), data: { turbo_frame: '_top' }, class: link_css
      end
    else
      name = _('Customise') if name.blank?
      link_to name,
              org_admin_template_customizations_path(template.id), data: { turbo_method: 'post', turbo_frame: '_top' },
                                                                   class: link_css
    end
  end
end
