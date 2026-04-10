# frozen_string_literal: true

# Helper methods for forms using Data type
module RegistryInFormHelper
  def data_type_select_values
    [
      [_('Dataset'), 'dataset'],
      [_('Software'), 'software'],
      [_('Physical object'), 'physical_object']
    ]
  end

  def select_values_from_registry(values, locale)
    values.map { |t| [t['label'][LocaleService.to_gettext(locale:)], t['value']] }
  end
end
