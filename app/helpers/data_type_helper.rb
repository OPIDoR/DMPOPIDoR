# frozen_string_literal: true

# Helper methods for forms using Data type
module DataTypeHelper
  def data_type_select_values
    [
      [_('None'), 'none'],
      [_('Software'), 'software']
    ]
  end
end
