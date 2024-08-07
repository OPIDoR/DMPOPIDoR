# frozen_string_literal: true

# Logic that ensures that table tags are allowed from TinyMCE editor results
class TableFreeScrubber < Rails::Html::PermitScrubber
  TABLE_TAGS = %w[table thead tbody tr td th tfoot caption].freeze

  ALLOWED_TAGS = Rails.application.config.action_view.sanitized_allowed_tags - TABLE_TAGS

  def initialize
    super
    self.tags = ALLOWED_TAGS
  end
end
