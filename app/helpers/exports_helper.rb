# frozen_string_literal: true

# Helper methods for Plan exports
module ExportsHelper
  # --------------------------------
  # Start DMP OPIDoR Customization
  # SEE app/helpers/dmpopidor/exports_helper.rb
  # --------------------------------
  prepend Dmpopidor::ExportsHelper
  # --------------------------------
  # End DMP OPIDoR Customization
  # --------------------------------

  PAGE_MARGINS = {
    top: '5',
    bottom: '10',
    left: '12',
    right: '12'
  }.freeze

  def font_face
    @formatting[:font_face].presence || 'Roboto, Arial, Sans-Serif'
  end

  def font_size
    @formatting[:font_size].presence || '12'
  end

  def margin_top
    get_margin_value_for_side(:top)
  end

  def margin_bottom
    get_margin_value_for_side(:bottom)
  end

  def margin_left
    get_margin_value_for_side(:left)
  end

  def margin_right
    get_margin_value_for_side(:right)
  end

  # --------------------------------
  # Start DMP OPIDoR Customization
  # SEE app/helpers/dmpopidor/exports_helper.rb
  # CHANGES: Changed prefix value to 'DMP Creator(s)'
  # --------------------------------
  def plan_attribution(attribution)
    attribution = Array(attribution)
    prefix = attribution.many? ? _('Creators:') : _('Creator:')
    "<strong>#{prefix}</strong> #{attribution.join(', ')}"
  end
  # --------------------------------
  # End DMP OPIDoR Customization
  # --------------------------------

  private

  def get_margin_value_for_side(side)
    side = side.to_sym
    if @formatting.dig(:margin, side).is_a?(Integer)
      @formatting[:margin][side] * 4
    else
      @formatting.dig(:margin, side).presence || PAGE_MARGINS[side]
    end
  end
end
