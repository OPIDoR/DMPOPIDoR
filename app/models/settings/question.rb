# frozen_string_literal: true

# == Schema Information
#
# Table name: settings
#
#  id          :integer          not null, primary key
#  target_type :string           not null
#  value       :text
#  var         :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  target_id   :integer          not null
#
# Indexes
#
#  settings_target_type_target_id_var_key  (target_type,target_id,var) UNIQUE
#

module Settings
  # Settings the questions
  class Question < RailsSettings::SettingObject
    AVAILABLE_CLASSNAMES = {
      'dataset' => %w[
        research_output_description
        data_reuse
        personal_data_issues
        legal_issues
        ethical_issues
        data_collection
        data_processing
        data_storage
        documentation_quality
        quality_assurance_method
        data_sharing
        data_preservation
      ],
      'software' => %w[
        software_description
        software_development
        software_documentation
        software_runtime
        software_preservation
        software_sharing
        software_legal_issues
        programming_language
        dependency_reference
        software_resource_reference
        software_valorisation
      ],
      'physical_object' => %w[
        physical_object_description
        physical_object_quality_documentation
        physical_object_storage
        physical_object_legal
        physical_object_sharing
      ]
    }.freeze
  end
end
