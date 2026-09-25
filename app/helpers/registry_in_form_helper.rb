# frozen_string_literal: true

# Helper methods for forms using Data type
module RegistryInFormHelper
  def data_type_select_values
    [
      [_('Data'), 'dataset'],
      [_('Software, source code'), 'software'],
      [_('Collection of physical objects'), 'physical_object']
    ]
  end

  def select_values_from_registry(values, locale)
    values.map { |t| [t['label'][LocaleService.to_gettext(locale:)], t['value']] }
  end
end
