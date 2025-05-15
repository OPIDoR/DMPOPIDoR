# frozen_string_literal: true

module Import
  # Service used to import a plan from a JSON document
  class PlanImportService
    class << self
      # rubocop:disable Metrics/AbcSize
      def import(plan, json_data, import_format)
        dmp_fragment = plan.json_fragment
        if import_format.eql?('rda')
          dmp = Import::Converters::RdaToStandardConverter.convert(json_data['dmp'])
          contributors = Import::Converters::RdaToStandardConverter.convert_contributors(json_data.dig('dmp',
                                                                                                       'contributor'))
          handle_contributors(dmp_fragment, contributors)
        else
          dmp = json_data
        end
        plan_title = format(_('Import of %{title}'), title: dmp.dig('meta', 'title'))
        dmp['meta']['title'] = plan_title
        dmp_template_name = plan.template.research_entity? ? 'DMPResearchEntity' : 'DMPResearchProject'
        dmp_fragment.raw_import(
          dmp.slice('meta', 'project', 'researchEntity', 'budget'), MadmpSchema.find_by(name: dmp_template_name)
        )
        Import::PlanImportService.handle_research_outputs(plan, dmp['researchOutput'])

        plan.update(title: plan_title)
      end
      # rubocop:enable Metrics/AbcSize

      # rubocop:disable Metrics/AbcSize
      def handle_research_outputs(plan, research_outputs)
        I18n.with_locale plan.template.locale do
          research_outputs.each_with_index do |ro_data, idx|
            max_order = plan.research_outputs.empty? ? 1 : plan.research_outputs.count + 1
            configuration = ro_data['configuration'] || {}
            description_prop_name, = ResearchOutput.data_type_to_schema_data(plan, configuration['dataType'],
                                                                             plan.template.locale)
            research_output = plan.research_outputs.create!(
              abbreviation: ro_data[description_prop_name]['shortName'] || "#{_('RO')} #{max_order}",
              title: ro_data[description_prop_name]['title'] || "#{_('Research output')} #{max_order}",
              is_default: idx.eql?(0),
              display_order: idx + 1
            )
            research_output.create_json_fragments(configuration.deep_symbolize_keys)
            module_id = research_output.module_id
            ro_frag = research_output.json_fragment
            plan_template = module_id.present? ? Template.find(module_id) : plan.template
            import_research_output(ro_frag, ro_data, plan, plan_template)
            ro_frag.research_output_description.update_research_output_parameters(skip_broadcast: true)
          end
        end
      end
      # rubocop:enable Metrics/AbcSize

      def handle_contributors(dmp_fragment, contributors)
        schema = MadmpSchema.find_by(name: 'PersonStandard')
        contributors.each do |contributor|
          next if MadmpFragment.fragment_exists?(contributor, schema, dmp_fragment.id, nil)

          Fragment::Person.create!(
            data: contributor,
            dmp_id: dmp_fragment.id,
            madmp_schema: schema,
            additional_info: { property_name: 'person' }
          )
        end
      end

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def import_research_output(research_output_fragment, research_output_data, plan, template)
        dmp_id = research_output_fragment.dmp_id
        research_output_data.each do |prop, content| # rubocop:disable Metrics/BlockLength
          next if prop.eql?('research_output_id')

          schema_prop = research_output_fragment.madmp_schema.schema['properties'][prop]
          next if schema_prop&.dig('type').nil?

          if research_output_fragment.data[prop].nil?
            # Fetch the associated question
            associated_question = template.questions.joins(:madmp_schema).find_by(madmp_schema: {
                                                                                    name: schema_prop['template_name']
                                                                                  })
            next if associated_question.nil?

            fragment = MadmpFragment.new(
              dmp_id:,
              parent_id: research_output_fragment.id,
              madmp_schema: associated_question.madmp_schema,
              additional_info: { 'property_name' => prop }
            )
            fragment.classname = associated_question.madmp_schema.classname
            next if associated_question.nil?

            # Create a new answer for the question associated to the fragment
            fragment.answer = Answer.create(
              question_id: associated_question.id,
              research_output_id: research_output_fragment.research_output_id,
              plan_id: plan.id, user_id: plan.owner.id
            )
            fragment.save!
          else
            fragment = MadmpFragment.find(research_output_fragment.data[prop]['dbid'])
          end
          fragment.raw_import(content, fragment.madmp_schema, fragment.id)
        end
      end
      # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

      def validate(json_data, import_format, locale: I18n.default_locale)
        I18n.with_locale locale do
          return [_('Invalid JSON data')] if json_data.nil?
          return [_('Invalid format')] unless %w[rda standard].include?(import_format)

          errs = []
          if import_format.eql?('rda')
            return [_('File should begin with :dmp property')] unless json_data['dmp'].present?

            errs = Import::Validators::Rda.validation_errors(json: json_data['dmp'].deep_symbolize_keys)
          else
            errs = Import::Validators::Standard.validation_errors(json: json_data)
          end
          errs
        end
      end
    end
  end
end
