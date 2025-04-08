# frozen_string_literal: true

# rubocop:disable Naming/VariableNumber
namespace :data_migration do
  desc 'Cleaning data'
  task V4_3_0: :environment do
    p 'Upgrading to DMP OPIDoR v4.3.0'
    p '------------------------------------------------------------------------'
    Rake::Task['data_migration:change_contributors_cardinality'].execute
    Rake::Task['data_migration:change_person_fragments_nametype'].execute
    Rake::Task['data_migration:remove_dmpkeyword_number_from_meta'].execute
    Rake::Task['data_migration:remove_funder_datapolicy'].execute
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
      meta_fragment.update_column(
        :data, meta_fragment.data.merge('contact' => [contact])
      )
    end
    p 'Changing project.principalInvestigator'
    p '------------------------------------------------------------------------'
    Fragment::Project.all.each do |project_fragment|
      pi = project_fragment.data['principalInvestigator']
      project_fragment.update_column(
        :data, project_fragment.data.merge('principalInvestigator' => [pi])
      )
    end
    p 'Changing researchOutputDescription.contact'
    p '------------------------------------------------------------------------'
    Fragment::ResearchOutputDescription.all.each do |rod_fragment|
      contact = rod_fragment.data['contact']
      rod_fragment.update_column(
        :data, rod_fragment.data.merge('contact' => [contact])
      )
    end
    p '------------------------------------------------------------------------'
    p 'Done'
  end
  desc 'Change Person fragment nameType to "Personal" or "Organisational"'
  task change_person_fragments_nametype: :environment do
    Fragment::Person.all.each do |person|
      updated_nametype = if %w[Personne Personal].include?(person.data['nameType']) # rubocop:disable Performance/CollectionLiteralInLoop
                           'Personal'
                         else
                           'Organizational'
                         end
      person.update_column(
        data: person.data.merge('nameType' => updated_nametype)
      )
    end
  end
  desc 'Remove dmpKeyword number from Meta fragments'
  task remove_dmpkeyword_number_from_meta: :environment do
    Fragment::Meta.all.each do |meta_fragment|
      dmp_keywords = meta_fragment.data['dmpKeyword']
      updated_kw = []

      if dmp_keywords.present? && dmp_keywords.length.positive?
        dmp_keywords.each do |kw|
          /^\d\.\d /.match?(kw) ? updated_kw.push(kw[4..kw.length - 1]) : updated_kw.push(kw)
        end
      end
      meta_fragment.update_column(
        data: meta_fragment.data.merge('dmpKeyword' => updated_kw)
      )
    end
  end
  desc 'Remove funder.dataPolicy'
  task remove_funder_datapolicy: :environment do
    Fragment::Funder.all.each do |funder|
      updated_data = funder.data
      next unless updated_data['dataPolicy'].present?

      dbid = updated_data.dig('dataPolicy', 'dbid')
      MadmpFragment.find(dbid).destroy if dbid.present?
      updated_data.delete('dataPolicy')
    end
  end
end
# rubocop:enable Naming/VariableNumber
