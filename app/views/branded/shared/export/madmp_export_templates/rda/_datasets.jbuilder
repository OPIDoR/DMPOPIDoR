# frozen_string_literal: true

ethical_issues_exist = []
ethical_issues_description = []
ethical_issues_report = []
excluded_types = %w[software logiciel].freeze

# rubocop:disable Metrics/BlockLength
json.dataset research_outputs do |research_output|
  dataset = research_output.json_fragment
  next if excluded_types.include?(dataset.research_output_description.data["type"].downcase)
  next unless selected_datasets.include?(dataset.data["research_output_id"])

  dataset_title = dataset.research_output_description.data["title"]
  json.dataset_id do
    json.identifier dataset.research_output_description.data["datasetId"] || dataset.data["research_output_id"]
    if dataset.research_output_description.data["datasetId"].present?
      json.type Export::Converters::RdaRegistryConverter.convert_pid_system(
        dataset.research_output_description.data["idType"]
      )
    else
      json.type 'other'
    end
  end
  json.description                exportable_description(dataset.research_output_description.data["description"])
  json.issued                     dataset.research_output_description.data["issuedDate"]
  json.keyword                    extract_keywords(dataset.research_output_description)
  json.language                   dataset.research_output_description.data["language"]
  json.personal_data              Export::Converters::RdaRegistryConverter.convert_yes_no(
    dataset.research_output_description.data["containsPersonalData"]
  )
  if dataset.preservation_issues.present?
    json.preservation_statement     exportable_description(dataset.preservation_issues.data["description"])
  else
    json.preservation_statement     ""
  end
  json.title                      dataset_title
  json.type                       dataset.research_output_description.data["type"]
  json.sensitive_data             Export::Converters::RdaRegistryConverter.convert_yes_no(
    dataset.research_output_description.data["containsSensitiveData"]
  )
  if dataset.sharing.present?
    distributions = if dataset.sharing.distribution.any?
                      dataset.sharing.distribution
                    else
                      [Fragment::Distribution.new(data: {})]
                    end
    json.distribution distributions do |distribution|
      start_date = distribution.data["licenseStartDate"] || nil

      json.access_url         distribution.data["accessUrl"]
      json.available_until    distribution.data["availableUntil"]
      json.byte_size          Export::Converters::RdaRegistryConverter.convert_bytes(distribution.data["fileVolume"],
                                                                                     distribution.data["volumeUnit"])
      json.data_access        Export::Converters::RdaRegistryConverter.convert_data_access(
        distribution.data["dataAccess"]
      )
      json.description        exportable_description(distribution.data["description"])
      json.download_url       distribution.data["downloadUrl"]
      json.format             distribution.data["fileFormat"].present? ? [distribution.data["fileFormat"]] : []
      json.title              distribution.data["fileName"]
      if dataset.sharing.host.present?
        host = dataset.sharing.host
        json.host do
          json.backup_frequency       ""
          json.backup_type            ""
          json.storage_type           ""
          json.description            exportable_description(host.data["description"])
          json.availability           host.data["availability"]
          json.certified_with         Export::Converters::RdaRegistryConverter.convert_certification(
            host.data["certification"]
          )
          json.geo_location host.data["geoLocation"]
          pid_system = if host.data["pidSystem"].present?
                         host.data["pidSystem"].map do |ps|
                           Export::Converters::RdaRegistryConverter.convert_pid_system(ps)
                         end
                       end
          json.pid_system             pid_system || []
          json.support_versioning     Export::Converters::RdaRegistryConverter.convert_yes_no(
            host.data["hasVersioningPolicy"]
          )
          json.title                  host.data["title"]
          json.url                    host.data["hostId"]
        end
      else
        # rubocop:disable Lint/EmptyBlock
        json.host {}
        # rubocop:enable Lint/EmptyBlock
      end
      json.license do
        json.child! do
          json.license_ref            distribution.license.present? ? distribution.license.data["licenseUrl"] : nil
          json.start_date             start_date
        end
      end
    end
  else
    json.distribution []
  end

  if dataset.documentation_quality.present?
    data_quality_assurance = [
      exportable_description(dataset.documentation_quality.data["description"])
    ]
    if dataset.quality_assurance_method.present?
      data_quality_assurance.append(exportable_description(dataset.quality_assurance_method.data["description"]))
    end
    json.data_quality_assurance data_quality_assurance.present? ? data_quality_assurance.compact : []
    json.metadata dataset.documentation_quality.metadata_standard do |metadata_standard|
      # rubocop:disable Layout/LineLength
      json.description        exportable_description("#{metadata_standard.data['name']} - #{metadata_standard.data['description']}")
      # rubocop:enable Layout/LineLength
      json.language           dataset.documentation_quality.data["metadataLanguage"]
      json.metadata_standard_id do
        json.identifier metadata_standard.data["metadataStandardId"]
        json.type       Export::Converters::RdaRegistryConverter.convert_pid_system(metadata_standard.data["idType"],
                                                                                    is_metadata_standard: true)
      end
    end
  else
    json.metadata []
  end

  if dataset.data_storage.present?
    json.security_and_privacy do
      json.child! do
        json.description        exportable_description(dataset.data_storage.data["securityMeasures"])
        json.title              "Security measures"
      end
    end
  else
    # rubocop:disable Lint/EmptyBlock
    json.security_and_privacy {}
    # rubocop:enable Lint/EmptyBlock
  end
  json.technical_resource dataset.technical_resources do |technical_resource|
    json.description        exportable_description(technical_resource.data["description"])
    json.title              technical_resource.data["title"]
  end

  ethical_issues_exist.push(dataset.research_output_description.data['hasEthicalIssues'])
  if dataset.ethical_issues.present?
    # rubocop:disable Layout/LineLength
    ethical_issues_description.push(exportable_description("#{dataset_title} : #{dataset.ethical_issues.data['description']}"))
    # rubocop:enable Layout/LineLength
    ethical_issues_report.push(
      "#{dataset_title} : #{dataset.ethical_issues.resource_reference.pluck(
        Arel.sql("data->'docIdentifier'")
      ).join(', ')}"
    )
  end
end
# rubocop:enable Metrics/BlockLength
I18n.with_locale plan.template.locale do
  intersect_yes = %w[Yes Oui] & ethical_issues_exist
  intersect_unknown = ["Unknown", "Ne sais pas"] & ethical_issues_exist
  exists = if intersect_yes.any?
             _('Yes')
           elsif intersect_unknown.any?
             intersect_unknown.first
           else
             _('No')
           end
  json.ethical_issues_exist         Export::Converters::RdaRegistryConverter.convert_yes_no(exists)
  json.ethical_issues_description   ethical_issues_description.join(" / ")
  json.ethical_issues_report        ethical_issues_report.join(" / ")
end
