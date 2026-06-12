# frozen_string_literal: true

module Export
  module RdaV11
    # Service used to convert a Standard Format DMP to RDA DMP Commons Standars Format
    class StandardToRda
      include MadmpExportHelper

      def initialize(plan, selected_research_outputs = [])
        @plan = plan
        @selected_research_outputs = selected_research_outputs
        @ethical_issues_exist = ['pouet']
        @ethical_issues_description = []
        @ethical_issues_report = []
      end

      # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      def call
        dmp = @plan.json_fragment
        meta = dmp.meta
        project = dmp.project
        research_outputs = @plan.research_outputs.order(:display_order)
        {
          created: Export::RdaV11::Converters::RdaRegistryConverter.convert_date_to_iso8601(meta.data['creationDate']),
          description: exportable_description(meta.data['description']),
          dmp_id: {
            identifier: meta.data['dmpId'] || Rails.application.routes.url_helpers.plan_url(id: dmp.data['plan_id']),
            type: Export::RdaV11::Converters::RdaRegistryConverter.convert_pid_system(
              meta.data['dmpId'] ? meta.data['idType'] : 'URL'
            )
          },
          language: meta.data['dmpLanguage'],
          modified: Export::RdaV11::Converters::RdaRegistryConverter.convert_date_to_iso8601(meta.data['lastModifiedDate']),
          title: meta.data['title'],
          contact: handle_contact(meta),
          contributor: handle_contributors(dmp),
          cost: handle_costs(dmp),
          project: [handle_project(project)],
          dataset: handle_datasets(research_outputs, @selected_research_outputs)
        }.merge(handle_ethical_issues)
      end
      # rubocop:enable Metrics/AbcSize,Metrics/MethodLength

      private

      def handle_contact(meta)
        contact = meta.contact[0]
        return {} unless contact.present?

        {
          contact_id: {
            identifier: contact.person.data['personId'],
            type: Export::RdaV11::Converters::RdaRegistryConverter.convert_agent_id_system(
              contact.person.data['idType'], is_person: true
            )
          },
          mbox: contact.person.data['mbox'],
          name: contact.person.to_s
        }
      end

      def handle_contributors(dmp)
        dmp.persons.filter_map do |person|
          roles = person.roles
          next if roles.empty?

          {
            name: person.to_s,
            mbox: person.data['mbox'],
            role: roles.uniq,
            contributor_id: {
              identifier: person.data['personId'],
              type: Export::RdaV11::Converters::RdaRegistryConverter.convert_agent_id_system(person.data['idType'],
                                                                                             is_person: true)
            }
          }
        end
      end

      def handle_costs(dmp)
        dmp.costs.map do |cost|
          {
            currency_code: cost.data['currency'],
            description: exportable_description(cost.data['description']) || cost.data['costType'],
            title: cost.data['title'],
            value: cost.data['amount']
          }
        end
      end

      def handle_project(project)
        start_date = project.data['startDate'] || nil
        end_date = project.data['endDate'] || nil
        {
          description: exportable_description(project.data['description']),
          title: project.data['title'],
          start: start_date,
          end: end_date,
          funding: handle_fundings(project.fundings)
        }
      end

      def handle_fundings(fundings)
        fundings.map do |funding|
          {
            funder_id: {
              identifier: funding.funder.data['funderId'],
              type: Export::RdaV11::Converters::RdaRegistryConverter.convert_agent_id_system(
                funding.funder.data['idType']
              )
            },
            funding_status: Export::RdaV11::Converters::RdaRegistryConverter.convert_funding_status(
              funding.data['fundingStatus']
            ),
            grant_id: {
              identifier: funding.data['grantId'],
              type: 'other'
            }
          }
        end
      end

      # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      def handle_datasets(research_outputs, _selected_research_outputs)
        # rubocop:disable Metrics/BlockLength
        research_outputs.order(:display_order).filter_map do |research_output|
          dataset = research_output.json_fragment
          next unless dataset.additional_info['dataType'].eql?('dataset')

          # next unless @selected_research_outputs.include?(dataset.data['research_output_id'])
          dataset_title = dataset.research_output_description.data['title']

          @ethical_issues_exist.push(dataset.research_output_description.data['hasEthicalIssues'])
          if dataset.ethical_issues.present?
            # rubocop:disable Layout/LineLength
            @ethical_issues_description.push(exportable_description("#{dataset_title} : #{dataset.ethical_issues.data['description']}"))
            # rubocop:enable Layout/LineLength
            @ethical_issues_report.push(
              "#{dataset_title} : #{dataset.ethical_issues.resource_reference.pluck(
                Arel.sql("data->'docIdentifier'")
              ).join(', ')}"
            )
          end

          {
            dataset_id: handle_dataset_id(dataset),
            description: exportable_description(dataset.research_output_description.data['description']),
            issued: dataset.research_output_description.data['issuedDate'],
            keyword: extract_keywords(dataset.research_output_description),
            language: dataset.research_output_description.data['language'],
            personal_data: Export::RdaV11::Converters::RdaRegistryConverter.convert_yes_no(
              dataset.research_output_description.data['containsPersonalData']
            ),
            preservation_statement: dataset.preservation_issues.present? ? exportable_description(dataset.preservation_issues.data['description']) : '', # rubocop:disable Layout/LineLength
            title: dataset_title,
            type: dataset.research_output_description.data['type'],
            sensitive_data: Export::RdaV11::Converters::RdaRegistryConverter.convert_yes_no(
              dataset.research_output_description.data['containsSensitiveData']
            ),
            distribution: handle_distributions(dataset),
            data_quality_assurance: handle_data_quality_assurance(dataset),
            metadata: handle_metadata(dataset),
            security_and_privacy: [handle_security_and_privacy(dataset)],
            technical_resource: handle_technical_resources(dataset)
          }
        end
        # rubocop:enable Metrics/BlockLength
      end
      # rubocop:enable Metrics/AbcSize,Metrics/MethodLength

      def handle_dataset_id(dataset)
        {
          identifier: dataset.research_output_description.data['datasetId'] || dataset.data['research_output_id'],
          type: if dataset.research_output_description.data['datasetId'].present?
                  Export::RdaV11::Converters::RdaRegistryConverter.convert_pid_system(
                    dataset.research_output_description.data['idType']
                  )
                else
                  'other'
                end
        }
      end

      # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      def handle_distributions(dataset)
        return [] unless dataset.sharing.present?

        distributions = if dataset.sharing.distribution.any?
                          dataset.sharing.distribution
                        else
                          [Fragment::Distribution.new(data: {})]
                        end
        distributions.map do |distribution|
          {
            access_url: distribution.data['accessUrl'],
            available_until: distribution.data['availableUntil'],
            byte_size: Export::RdaV11::Converters::RdaRegistryConverter.convert_bytes(
              distribution.data['fileVolume'], distribution.data['volumeUnit']
            ),
            data_access: Export::RdaV11::Converters::RdaRegistryConverter.convert_data_access(distribution.data['dataAccess']),
            description: exportable_description(distribution.data['description']),
            download_url: distribution.data['downloadUrl'],
            format: distribution.data['fileFormat'].present? ? [distribution.data['fileFormat']] : [],
            title: distribution.data['fileName'],
            host: handle_host(dataset),
            license: [{
              license_ref: distribution.license.present? ? distribution.license.data['licenseUrl'] : nil,
              start_date: distribution.data['licenseStartDate'] || nil
            }]
          }
        end
      end
      # rubocop:enable Metrics/AbcSize,Metrics/MethodLength

      # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      def handle_host(dataset)
        return {} unless dataset.sharing.host.present?

        host = dataset.sharing.host
        {
          backup_frequency: '',
          backup_type: '',
          storage_type: '',
          description: exportable_description(host.data['description']),
          availability: host.data['availability'],
          certified_with: Export::RdaV11::Converters::RdaRegistryConverter.convert_certification(host.data['certification']),
          geo_location: host.data['geoLocation'],
          pid_system: if host.data['pidSystem'].present?
                        host.data['pidSystem'].map do |ps|
                          Export::RdaV11::Converters::RdaRegistryConverter.convert_pid_system(ps)
                        end
                      else
                        []
                      end,
          support_versioning: Export::RdaV11::Converters::RdaRegistryConverter.convert_yes_no(host.data['supportVersioning']),
          title: host.data['title'],
          url: host.data['hostId']
        }
      end
      # rubocop:enable Metrics/AbcSize,Metrics/MethodLength

      def handle_data_quality_assurance(dataset)
        return [] unless dataset.documentation_quality.present?

        data_quality_assurance = [
          exportable_description(dataset.documentation_quality.data['description'])
        ]
        if dataset.quality_assurance_method.present?
          data_quality_assurance.append(exportable_description(dataset.quality_assurance_method.data['description']))
        end
        data_quality_assurance.present? ? data_quality_assurance.compact : []
      end

      # rubocop:disable Metrics/AbcSize
      def handle_metadata(dataset)
        return [] unless dataset.documentation_quality.present?

        dataset.documentation_quality.metadata_standard.map do |metadata_standard|
          {
            # rubocop:disable Layout/LineLength
            description: exportable_description("#{metadata_standard.data['name']} - #{metadata_standard.data['description']}"),
            # rubocop:enable Layout/LineLength
            language: dataset.documentation_quality.data['metadataLanguage'],
            metadata_standard_id: {
              identifier: metadata_standard.data['metadataStandardId'],
              type: Export::RdaV11::Converters::RdaRegistryConverter.convert_pid_system(
                metadata_standard.data['idType'], is_metadata_standard: true
              )
            }
          }
        end
      end
      # rubocop:enable Metrics/AbcSize

      def handle_security_and_privacy(dataset)
        return {} unless dataset.data_storage.present?

        {
          description: exportable_description(dataset.data_storage.data['securityMeasures']),
          title: 'Security measures'
        }
      end

      def handle_technical_resources(dataset)
        return [] unless dataset.technical_resources.present?

        dataset.technical_resources.map do |technical_resource|
          {
            description: exportable_description(technical_resource.data['description']),
            title: technical_resource.data['title']
          }
        end
      end

      def handle_ethical_issues
        I18n.with_locale @plan.template.locale do
          intersect_yes = %w[Yes Oui] & @ethical_issues_exist
          intersect_unknown = ['Unknown', 'Ne sais pas'] & @ethical_issues_exist
          exists = if intersect_yes.any?
                     _('Yes')
                   elsif intersect_unknown.any?
                     intersect_unknown.first
                   else
                     _('No')
                   end
          {
            ethical_issues_exist: Export::RdaV11::Converters::RdaRegistryConverter.convert_yes_no(exists),
            ethical_issues_description: @ethical_issues_description.join(' / '),
            ethical_issues_report: @ethical_issues_report.join(' / ')
          }
        end
      end
    end
  end
end
