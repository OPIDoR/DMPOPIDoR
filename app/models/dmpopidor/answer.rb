# frozen_string_literal: true

module Dmpopidor
  # Customized code for Answer model
  module Answer
    # rubocop:disable Metrics/AbcSize
    def instantiate_fragment
      if plan.structured? && madmp_fragment.nil?
        dmp_id = plan.json_fragment.id
        madmp_schema = MadmpSchema.find(question.madmp_schema_id)
        defaults = madmp_schema.defaults(plan.template.locale)
        madmp_fragment = MadmpFragment.create!(
          data: {},
          answer_id: id,
          parent_id: research_output.present? ? research_output.json_fragment.id : nil,
          dmp_id:,
          madmp_schema: madmp_schema,
          classname: madmp_schema.classname,
          additional_info: {
            'property_name' => madmp_schema.property_name_from_classname
          }
        )
        madmp_fragment.instantiate
        madmp_fragment.handle_defaults(defaults)
        madmp_fragment.id
      end
      nil
    end
    # rubocop:enable Metrics/AbcSize
  end
end
