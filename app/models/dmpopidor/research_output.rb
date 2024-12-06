# frozen_string_literal: true

module Dmpopidor
  # Customized code for ResearchOutput model
  # rubocop:disable Metrics/ModuleLength
  module ResearchOutput
    def main?
      display_order.eql?(1)
    end

    # Return main research output
    def main
      plan.research_outputs.first
    end

    def common_answers?(section_id)
      answers.each do |answer|
        return true if answer.question_id.in?(Section.find(section_id).questions.pluck(:id)) && answer.is_common
      end
      false
    end

    # Generates a new uuid
    def generate_uuid!
      new_uuid = ::ResearchOutput.unique_uuid(field_name: 'uuid')
      update_column(:uuid, new_uuid)
    end

    def get_answers_for_section(section_id)
      answers.select { |answer| answer.question_id.in?(Section.find(section_id).questions.pluck(:id)) }
    end

    def json_fragment
      Fragment::ResearchOutput.where("(data->>'research_output_id')::int = ?", id).first
    end

    def destroy_json_fragment
      Fragment::ResearchOutput.where("(data->>'research_output_id')::int = ?", id).destroy_all
    end

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def create_json_fragments(configuration = {})
      # rubocop:disable Metrics/BlockLength
      I18n.with_locale plan.template.locale do
        fragment = json_fragment
        dmp_fragment = plan.json_fragment
        contact_person = dmp_fragment.persons.first
        data_type = configuration[:dataType]
        if fragment.nil?
          description_prop_name, description_question, description_schema = data_type_to_schema_data(data_type)

          # Creates the main ResearchOutput fragment
          fragment = Fragment::ResearchOutput.create(
            data: {
              'research_output_id' => id
            },
            madmp_schema: MadmpSchema.find_by(classname: 'research_output', data_type: data_type || 'none'),
            dmp_id: dmp_fragment.id,
            parent_id: dmp_fragment.id,
            additional_info: {
              property_name: 'researchOutput',
              hasPersonalData: configuration[:hasPersonalData] || false,
              dataType: data_type || 'none',
              moduleId: ::Template.module(data_type:)&.id
            }
          )
          fragment_description = MadmpFragment.create!(
            data: {
              'title' => title,
              'datasetId' => pid,
              'type' => output_type_description,
              'containsPersonalData' => configuration[:hasPersonalData] ? _('Yes') : _('No')
            },
            madmp_schema: description_schema,
            classname: description_schema.classname,
            dmp_id: dmp_fragment.id,
            parent_id: fragment.id,
            additional_info: { property_name: description_prop_name }
          )
          fragment_description.instantiate
          Fragment::Contributor.find_by(parent_id: fragment_description.id).update(
            data: {
              'person' => contact_person.present? ? { 'dbid' => contact_person.id } : nil,
              'role' => _('Contact Person')
            }
          )

          if description_question.present? && plan.template.structured?
            # Create a new answer for the ResearchOutputDescription Question
            # This answer will be displayed in the Write Plan tab,
            # pre filled with the ResearchOutputDescription info
            fragment_description.answer = ::Answer.create(
              question_id: description_question.id,
              research_output_id: id,
              plan_id: plan.id,
              user_id: plan.users.first.id
            )
            fragment_description.save!
          end
        else
          data = fragment.research_output_description.data.merge(
            {
              'title' => title,
              'datasetId' => pid,
              'type' => output_type_description
            }
          )
          fragment.research_output_description.update(data: data)
        end
      end
      # rubocop:enable Metrics/BlockLength
    end
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    def serialize_infobox_data
      description_fragment = json_fragment.research_output_description
      {
        abbreviation: abbreviation,
        title: description_fragment.data['title'],
        type: description_fragment.data['type'],
        configuration: {
          hasPersonalData: personal_data?
        }
      }
    end

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def serialize_json
      ro_fragment = json_fragment
      module_id = ro_fragment.additional_info['moduleId']
      template = module_id ? ::Template.find(module_id) : plan.template

      guidance_presenter = ::GuidancePresenter.new(plan)
      questions_with_guidance = template.questions.select do |q|
        question = ::Question.find(q.id)
        guidance_presenter.any?(question:)
      end.pluck(:id)

      I18n.with_locale plan.template.locale do
        return {
          id: id,
          uuid: uuid,
          abbreviation: abbreviation,
          title: title,
          order: display_order,
          type: ro_fragment.research_output_description['data']['type'] || nil,
          configuration: ro_fragment.additional_info,
          answers: answers.map do |a|
            {
              id: a.id,
              question_id: a.question_id,
              fragment_id: a.madmp_fragment.id,
              madmp_schema_id: a.madmp_fragment.madmp_schema_id
            }
          end,
          questions_with_guidance:,
          template: template.serialize_json
        }
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    def personal_data?
      json_fragment.additional_info['hasPersonalData'] || false
    end

    private

    #####
    # Returns an array containing the property name, description question & the madmpschema according to the
    # data_type in parameters
    #####
    def data_type_to_schema_data(data_type)
      if data_type.eql?('software') && MadmpSchema.exists?(name: 'SoftwareDescriptionStandard')
        [
          'softwareDescription',
          ::Template.module(data_type:).questions.joins(:madmp_schema).find_by(madmp_schemas: { classname: 'software_description' }), # rubocop:disable Layout/LineLength
          MadmpSchema.find_by(name: 'SoftwareDescriptionStandard')
        ]
      else
        [
          'researchOutputDescription',
          plan.questions.joins(:madmp_schema).find_by(madmp_schemas: { classname: 'research_output_description' }),
          MadmpSchema.find_by(name: 'ResearchOutputDescriptionStandard')
        ]
      end
    end
  end
  # rubocop:enable Metrics/ModuleLength
end
