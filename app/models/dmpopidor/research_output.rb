# frozen_string_literal: true

module Dmpopidor

  module ResearchOutput

    def main?
      order.eql?(1)
    end

    # Return main research output
    def main
      plan.research_outputs.first
    end

    def common_answers?(section_id)
      answers.each do |answer|
        if answer.question_id.in?(Section.find(section_id).questions.pluck(:id)) && answer.is_common
          return true
        end
      end
      false
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

    def create_json_fragments
      FastGettext.with_locale plan.template.locale do
        fragment = json_fragment
        dmp_fragment = plan.json_fragment
        contact_person = dmp_fragment.persons.first
        if fragment.nil?
          # Fetch the first question linked with a ResearchOutputDescription schema
          description_question = plan.questions.joins(:madmp_schema)
                                     .find_by(madmp_schemas: { classname: "research_output_description" } )

          # Creates the main ResearchOutput fragment
          fragment = Fragment::ResearchOutput.create(
            data: {
              "research_output_id" => id
            },
            madmp_schema: MadmpSchema.find_by(classname: "research_output"),
            dmp_id: dmp_fragment.id,
            parent_id: dmp_fragment.id,
            additional_info: { property_name: "researchOutput" }
          )
          fragment_description = Fragment::ResearchOutputDescription.new(
            data: {
              "title" => fullname,
              "datasetId" => pid
            },
            madmp_schema: MadmpSchema.find_by(name: "ResearchOutputDescriptionStandard"),
            dmp_id: dmp_fragment.id,
            parent_id: fragment.id,
            additional_info: { property_name: "researchOutputDescription" }
          )
          fragment_description.instantiate
          fragment_description.contact.update(
            data: {
              "person" => { "dbid" => contact_person.id },
              "role" => d_("dmpopidor", "Data contact")
            }
          )

          if description_question.present? && plan.template.structured?
            # Create a new answer for the ResearchOutputDescription Question
            # This answer will be displayed in the Write Plan tab, pre filled with the ResearchOutputDescription info
            fragment_description.answer = Answer.create(
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
              "title" => fullname,
              "datasetId" => pid,
              "type" => other_type_label
            }
          )
          fragment.research_output_description.update(data: data)
        end
      end
    end

    ##
    # deep copy the given research output
    #
    # Returns Research output
    def self.deep_copy(research_output)
      research_output.dup
    end

  end

end