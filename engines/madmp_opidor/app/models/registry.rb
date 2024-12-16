# frozen_string_literal: true

# == Schema Information
#
# Table name: registries
#
#  id          :integer          not null, primary key
#  description :string
#  name        :string           not null
#  uri         :string
#  version     :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  org_id      :integer
#
# Indexes
#
#  index_registries_on_org_id  (org_id)
#
# Foreign Keys
#
#  fk_rails_...  (org_id => orgs.id)
#

# Object that represents a registry
class Registry < ApplicationRecord
  include ValidationMessages

  # ================
  # = Associations =
  # ================

  belongs_to :org, optional: true

  # ===============
  # = Validations =
  # ===============

  validates :name, presence: { message: PRESENCE_MESSAGE }

  # ==========
  # = Scopes =
  # ==========

  scope :search, lambda { |term|
    search_pattern = "%#{term}%"
    where('lower(registries.name) LIKE lower(?) OR ' \
          'lower(registries.description) LIKE lower(?)',
          search_pattern, search_pattern)
  }

  # rubocop:disable Metrics/AbcSize
  def self.load_values(values_file, registry)
    return if values_file.nil?

    if values_file.respond_to?(:read)
      values_data = values_file.read
    elsif values_file.respond_to?(:path)
      values_data = File.read(values_file.path)
    else
      logger.error "Bad values_file: #{values_file.class.name}: #{values_file.inspect}"
    end
    begin
      json_values = JSON.parse(values_data)
      if json_values.key?(registry.name)
        registry.update(values: json_values[registry.name])
      else
        flash.now[:alert] = 'Wrong values file format'
      end
    rescue JSON::ParserError
      flash.now[:alert] = 'File should contain JSON'
    end
  end
  # rubocop:enable Metrics/AbcSize
end
