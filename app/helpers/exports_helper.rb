# frozen_string_literal: true

# Helper methods for Plan exports
module ExportsHelper
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
  # CHANGES: Changed prefix value to 'DMP Creator(s)'
  # --------------------------------
  def plan_attribution(attribution)
    attribution = Array(attribution)
    prefix = attribution.many? ? _('DMP Creators:') : _('DMP Creator:')
    "<strong>#{prefix}</strong> #{attribution.join(', ')}"
  end

  def should_hide_question(question, research_output)
    return research_output.personal_data?.eql?(false) if question[:madmp_schema].classname.eql?('personal_data_issues')

    false
  end

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
