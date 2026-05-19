# frozen_string_literal: true

# rubocop:disable Naming/VariableNumber
namespace :data_migration do
  desc 'Cleaning data'
  task V4_3_7: :environment do
    p 'Upgrading to DMP OPIDoR v4.3.7'
    p '------------------------------------------------------------------------'
    Rake::Task['data_migration:update_orcid_id_types'].execute
    Rake::Task['data_migration:update_ror_affiliation_id_types'].execute
    Rake::Task['data_migration:update_ror_id_types'].execute
    p 'Upgrade complete'
  end
  desc 'Cleaning data'
  task V4_3_4: :environment do
    p 'Upgrading to DMP OPIDoR v4.3.4'
    p '------------------------------------------------------------------------'
    Rake::Task['data_migration:update_research_output_description'].execute
    p 'Upgrade complete'
  end
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
  desc 'Update ORCID idTypes in Person fragments from "ORCID iD" to "ORCID"'
  task update_orcid_id_types: :environment do
    p 'Updating ORCID idTypes in Person fragments...'
    Fragment::Person.all.each do |person|
      person_id = person.data['idType']
      next unless person_id.present? && person_id.downcase == 'orcid id'

      person.update_column(
        :data, person.data.merge('idType' => 'ORCID')
      )
    end
    p 'Done.'
  end
  desc 'Update ROR affiliationIdTypes in Person fragments from "ROR ID" to "ROR"'
  task update_ror_affiliation_id_types: :environment do
    p 'Updating ROR affiliationIdType in Person fragments...'
    Fragment::Person.all.each do |person|
      affiliation_id_type = person.data['affiliationIdType']
      next unless affiliation_id_type.present? && affiliation_id_type.downcase == 'ror id'

      person.update_column(
        :data, person.data.merge('affiliationIdType' => 'ROR')
      )
    end
    p 'Done.'
  end
  desc 'Update ROR idTypes in Funder, Partner & ResearchEntity fragments from "ROR ID" to "ROR"'
  task update_ror_id_types: :environment do
    p 'Updating ROR idType in Funder, Partner & ResearchEntity fragments...'
    p 'Updating ROR idType in Funder...'
    Fragment::Funder.all.each do |funder|
      id_type = funder.data['idType']
      next unless id_type.present? && id_type.downcase == 'ror id'

      funder.update_column(
        :data, funder.data.merge('idType' => 'ROR')
      )
    end
    p 'Updating ROR idType in Partner...'
    Fragment::Partner.all.each do |partner|
      id_type = partner.data['idType']
      next unless id_type.present? && id_type.downcase == 'ror id'

      partner.update_column(
        :data, partner.data.merge('idType' => 'ROR')
      )
    end
    p 'Updating ROR idType in ResearchEntity...'
    Fragment::ResearchEntity.all.each do |research_entity|
      id_type = research_entity.data['idType']
      next unless id_type.present? && id_type.downcase == 'ror id'

      research_entity.update_column(
        :data, research_entity.data.merge('idType' => 'ROR')
      )
    end
  end
  desc 'Update empty research output output_type_description with fragment description'
  task update_research_output_description: :environment do
    Fragment::ResearchOutput.all.each do |fragment|
      research_output = fragment.research_output
      fragment_type = fragment.research_output_description&.data&.[]('type')
      fragment_data_type = fragment.additional_info['dataType'].eql?('none') ? 'dataset' : fragment.additional_info['dataType'] # rubocop:disable Layout/LineLength
      if fragment_type.present?
        research_output.update_columns(output_type_description: fragment_type,
                                       output_type: fragment_data_type)
      end
    end
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
        :data, person.data.merge('nameType' => updated_nametype)
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
          /^\d\.\d /.match?(kw) ? updated_kw.push(kw[4..]) : updated_kw.push(kw)
        end
      end
      meta_fragment.update_column(
        :data, meta_fragment.data.merge('dmpKeyword' => updated_kw)
      )
    end
  end
  desc 'Remove funder.dataPolicy'
  task remove_funder_datapolicy: :environment do
    Fragment::Funder.all.each do |funder|
      updated_data = funder.data
      next unless updated_data['dataPolicy'].present?

      dbid = updated_data.dig('dataPolicy', 'dbid')
      MadmpFragment.find(dbid).delete if dbid.present?
      updated_data.delete('dataPolicy')
      funder.update_column(
        :data, updated_data
      )
    end
  end
end
# rubocop:enable Naming/VariableNumber
