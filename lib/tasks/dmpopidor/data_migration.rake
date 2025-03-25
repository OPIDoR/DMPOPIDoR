# frozen_string_literal: true

# rubocop:disable Naming/VariableNumber
namespace :data_migration do
  desc 'Cleaning data'
  task V4_3_0: :environment do
    p 'Upgrading to DMP OPIDoR v4.3.0'
    p '------------------------------------------------------------------------'
    Rake::Task['data_migration:change_contributors_cardinality'].execute
    p 'Upgrade complete'
  end
  task V4_1_0: :environment do
    p 'Upgrading to DMP OPIDoR v4.1.0'
    p '------------------------------------------------------------------------'
    Rake::Task['data_migration:fix_ro_fragment_haspersonaldata'].execute
    p 'Upgrade complete'
  end
  task V4_0_3: :environment do
    p 'Upgrading to DMP OPIDoR v4.0.3'
    p '------------------------------------------------------------------------'
    Rake::Task['data_migration:documentationquality_documentationsoftware_to_string_array'].execute
    Rake::Task['data_migration:clean_empty_metadatastandard'].execute
    Rake::Task['data_migration:clean_empty_host'].execute
    p '------------------------------------------------------------------------'
    p 'Upgrade complete'
  end
  desc 'Migrate DocumentationQuality.documentationSoftware to string array'
  task documentationquality_documentationsoftware_to_string_array: :environment do
    p 'Migrating DocumentationQuality.documentationSoftware  to string array'
    p '------------------------------------------------------------------------'
    Fragment::DocumentationQuality.all.each do |dq|
      documentation_software = dq.data['documentationSoftware']
      updated_data = dq.data.clone

      next if documentation_software.is_a?(Array) || !dq.data.key?('documentationSoftware')

      updated_data['documentationSoftware'] = if documentation_software.nil?
                                                []
                                              else
                                                [documentation_software]
                                              end
      dq.update_column(:data, updated_data)
    end
    p '------------------------------------------------------------------------'
    p 'Done'
  end
  desc 'Clean empty metadataStandard in Host'
  task clean_empty_metadatastandard: :environment do
    p 'Cleaning empty metadataStandard in Host'
    p '------------------------------------------------------------------------'
    Fragment::Host.all.each do |h|
      next if h.data['metadataStandard'].is_a?(Array)

      updated_data = h.data.clone
      metadata_standard_id = h.data.dig('metadataStandard', 'dbid')
      next if metadata_standard_id.nil?

      metadata_standard = MadmpFragment.find(metadata_standard_id)
      if metadata_standard.data.empty?
        updated_data.delete('metadataStandard')
      else
        updated_data.merge('metadataStandard' => [metadata_standard.data['name']])
      end
      metadata_standard.destroy

      h.update_column(:data, updated_data)
    end
    p '------------------------------------------------------------------------'
    p 'Done'
  end

  desc 'Clean empty hosts'
  task clean_empty_host: :environment do
    p 'Cleaning empty hosts'
    p '------------------------------------------------------------------------'
    Fragment::Host.all.each do |h|
      h.destroy if h.data.empty?
    end
    p '------------------------------------------------------------------------'
    p 'Done'
  end

  desc 'Fix research output fragment hasPersonalData configuration'
  task fix_ro_fragment_haspersonaldata: :environment do
    Plan.includes(:template).all.each do |plan|
      next unless plan.structured?

      non_no = %w[non no].freeze
      plan.research_outputs.each do |research_output|
        ro_fragment = research_output.json_fragment
        ro_fragment_description = ro_fragment.research_output_description
        new_additional_info = ro_fragment.additional_info
        new_additional_info = if non_no.include?(ro_fragment_description&.data&.dig('containsPersonalData')&.downcase)
                                new_additional_info.merge(
                                  'hasPersonalData' => false
                                )
                              else
                                new_additional_info.merge(
                                  'hasPersonalData' => true
                                )
                              end
        ro_fragment.update(additional_info: new_additional_info)
      end
    end
  end

  desc 'Change meta.contact, project.principalInvestigator & researchOutputDescription.contact to arrays'
  task change_contributors_cardinality: :environment do
    p 'Changing meta.contact'
    p '------------------------------------------------------------------------'
    Fragment::Meta.all.each do |meta_fragment|
      contact = meta_fragment.data['contact']
      meta_fragment.update(
        data: meta_fragment.data.merge('contact' => [contact])
      )
    end
    p 'Changing project.principalInvestigator'
    p '------------------------------------------------------------------------'
    Fragment::Project.all.each do |project_fragment|
      pi = project_fragment.data['principalInvestigator']
      project_fragment.update(
        data: project_fragment.data.merge('principalInvestigator' => [pi])
      )
    end
    p 'Changing researchOutputDescription.contact'
    p '------------------------------------------------------------------------'
    Fragment::ResearchOutputDescription.all.each do |rod_fragment|
      contact = rod_fragment.data['contact']
      rod_fragment.update(
        data: rod_fragment.data.merge('contact' => [contact])
      )
    end
    p '------------------------------------------------------------------------'
    p 'Done'
  end
end
# rubocop:enable Naming/VariableNumber
