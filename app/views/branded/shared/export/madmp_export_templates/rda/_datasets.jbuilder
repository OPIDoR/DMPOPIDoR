# frozen_string_literal: true

ethical_issues_exist = []
ethical_issues_description = []
ethical_issues_report = []

# rubocop:disable Metrics/BlockLength
json.dataset datasets do |dataset|
  next unless selected_datasets.include?(dataset.data["research_output_id"])

  dataset_title = dataset.research_output_description.data["title"]
  json.dataset_id do
    json.identifier     dataset.research_output_description.data["datasetId"] || dataset.data["research_output_id"]
    json.type           dataset.research_output_description.data["datasetId"].present? ? dataset.research_output_description.data["idType"] : d_("dmpopidor", "Local identifier")
  end
  json.description                exportable_description(dataset.research_output_description.data["description"])
  json.keyword                    extract_keywords(dataset.research_output_description)
  json.language                   dataset.research_output_description.data["language"]
  json.personal_data              dataset.research_output_description.data["containsPersonalData"]
  if dataset.preservation_issues.present?
    json.preservation_statement     exportable_description(dataset.preservation_issues.data["description"])
  else
    json.preservation_statement     ""
  end
  json.title                      dataset_title
  json.type                       dataset.research_output_description.data["type"]
  json.sensitive_data             dataset.research_output_description.data["containsSensitiveData"]
  if dataset.sharing.present?
    # json.issued               dataset.sharing.distribution.data["releaseDate"]
    json.issued ""
    json.distribution dataset.sharing.distribution do |distribution|
      start_date = distribution.data["licenseStartDate"] || nil

      json.access_url         distribution.data["accessUrl"]
      json.available_until    distribution.data["availableUntil"]
      json.byte_size          distribution.data["fileVolume"]
      json.data_access        distribution.data["dataAccess"]
      json.description        exportable_description(distribution.data["description"])
      json.download_url       distribution.data["downloadUrl"]
      json.format             distribution.data["fileFormat"]
      json.title              distribution.data["fileName"]
      if distribution.sharing.host.present?
        host = distribution.sharing.host
        json.host do
          json.backup_frequency       ""
          json.backup_type            ""
          json.storage_type           ""
          json.description            exportable_description(host.data["description"])
          json.availability           host.data["availability"]
          json.certified_with         host.data["certification"]
          json.geo_location           host.data["geoLocation"]
          json.pid_system             host.data["pidSystem"]
          json.support_versioning     host.data["hasVersioningPolicy"]
          json.title                  host.data["title"]
          json.url                    host.data["hostId"]
        end
      else
        json.host {}
      end
      json.license do
        json.license_ref            distribution.license.data["licenseUrl"]
        json.start_date             start_date
      end
    end
  else
    json.distribution []
  end

  if dataset.documentation_quality.present?
    json.data_quality_assurance exportable_description(dataset.documentation_quality.data["description"])
    json.metadata dataset.documentation_quality.metadata_standard do |metadata_standard|
      json.description        exportable_description("#{metadata_standard.data['name']} - #{metadata_standard.data['description']}")
      json.language           metadata_standard.data["metadataLanguage"]
      json.metadata_standard_id do 
        json.identifier metadata_standard.data["metadataStandardId"]
        json.type       metadata_standard.data["idType"]
      end
    end
  else
    json.metadata []
  end

  if dataset.data_storage.present?
    json.security_and_privacy do
      json.description        exportable_description(dataset.data_storage.data["securityMeasures"])
      json.title              "Security measures"
    end
  else
    json.security_and_privacy {}
  end
  json.technical_resource dataset.technical_resources do |technical_resource|
    json.description        exportable_description(technical_resource.data["description"])
    json.title              technical_resource.data["title"]
  end

  ethical_issues_exist.push("#{dataset_title} : #{dataset.research_output_description.data['hasEthicalIssues']}")
  if dataset.ethical_issues.present?
    ethical_issues_description.push(exportable_description("#{dataset_title} : #{dataset.ethical_issues.data['description']}"))
    ethical_issues_report.push(
      "#{dataset_title} : #{dataset.ethical_issues.resource_reference.pluck("data->'docIdentifier'").join(', ')}"
    )
  end
end
# rubocop:enable Metrics/BlockLength
json.ethical_issues_exist         ethical_issues_exist.join(" / ")
json.ethical_issues_description   ethical_issues_description.join(" / ")
json.ethical_issues_report        ethical_issues_report.join(" / ")