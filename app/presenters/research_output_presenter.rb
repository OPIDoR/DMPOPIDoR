# frozen_string_literal: true

# Helper methods for the research outputs tab
class ResearchOutputPresenter
  attr_accessor :research_output

  def initialize(research_output:)
    @research_output = research_output
  end

  # Returns the output_type list for a select_tag
  def selectable_output_types
    ResearchOutput.output_types
                  .map { |k, _v| [k.humanize, k] }
  end

  # Returns the access options for a select tag
  def selectable_access_types
    ResearchOutput.accesses
                  .map { |k, _v| [k.humanize, k] }
  end

  # Returns the options for file size units
  def selectable_size_units
    [%w[MB mb], %w[GB gb], %w[TB tb], %w[PB pb], ['bytes', '']]
  end

  # Returns whether or not we should capture the byte_size based on the output_type
  def byte_sizable?
    @research_output.audiovisual? || @research_output.sound? || @research_output.image? ||
      @research_output.model_representation? ||
      @research_output.data_paper? || @research_output.dataset? || @research_output.text?
  end

  # Converts the byte_size into a more friendly value (e.g. 15.4 MB)
  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
  def converted_file_size(size:)
    return { size: nil, unit: 'mb' } unless size.present? && size.is_a?(Numeric) && size.positive?
    return { size: size / 1.petabytes, unit: 'pb' } if size >= 1.petabytes
    return { size: size / 1.terabytes, unit: 'tb' } if size >= 1.terabytes
    return { size: size / 1.gigabytes, unit: 'gb' } if size >= 1.gigabytes
    return { size: size / 1.megabytes, unit: 'mb' } if size >= 1.megabytes

    { size: size, unit: '' }
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity

  # Returns the truncated title if it is greater than 50 characters
  def display_name
    return '' unless @research_output.is_a?(ResearchOutput)
    return "#{@research_output.title[0..49]} ..." if @research_output.title.length > 50

    @research_output.title
  end

  # Returns the humanized version of the output_type enum variable
  def display_type
    return '' unless @research_output.is_a?(ResearchOutput)
    # Return the user entered text for the type if they selected 'other'
    return @research_output.output_type_description if @research_output.other?

    @research_output.output_type.tr('_', ' ').capitalize
  end

  # Returns the humanized version of the access enum variable
  def display_access
    return _('Unspecified') unless @research_output.access.present?

    @research_output.access.capitalize
  end

  # Returns the release date as a date
  def display_release
    return _('Unspecified') unless @research_output.release_date.present?

    @research_output.release_date.to_date
  end

  # Return 'Yes', 'No' or 'Unspecified' depending on the value
  def display_boolean(value:)
    return 'Unspecified' if value.nil?

    value ? 'Yes' : 'No'
  end
end
