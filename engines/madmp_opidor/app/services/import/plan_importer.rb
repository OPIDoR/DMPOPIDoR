module Import
  class PlanImporter
    Result = Struct.new(:success?, :plan, :errors, keyword_init: true)

    def self.call(import_params, current_user)
      plan = import_params[:plan] || ::Plan.new
      plan.template = Template.find(import_params[:template_id])
      language = Language.find_by(abbreviation: plan.template.locale)
      ids = (Org.default_orgs.pluck(:id) << current_user.org_id).uniq
      ggs = GuidanceGroup.where(org_id: ids, optional_subset: false, published: true, language_id: language.id)
      plan.guidance_groups << ggs if ggs.present?

      json_data = parse_json(import_params[:json_file])
      return Result.new(success?: false, errors: ['invalid_file']) unless json_data

      errs = Import::PlanImportService.validate(json_data, import_params[:format], locale: plan.template.locale)
      return Result.new(success?: false, errors: errs) if errs.any?

      plan.visibility = Rails.configuration.x.plans.default_visibility
      plan.title = json_data.dig('meta', 'title') || "#{current_user.firstname}'s Plan"
      plan.org = current_user.org

      Plan.transaction do
        if plan.save
          plan.add_user!(current_user.id, :creator)
          plan.create_plan_fragments(json_data)
          Import::PlanImportService.import(plan, json_data, import_params[:format])
          plan.update(title: plan.json_fragment.meta.data['title'])

          Result.new(success?: true, plan: plan)
        else
          Result.new(success?: false, errors: plan.errors.full_messages)
        end
      end
    rescue JSON::ParserError
      Result.new(success?: false, errors: ['invalid_json'])
    rescue => e
      Rails.logger.error e.full_message
      Result.new(success?: false, errors: [e.message])
    end

    def self.parse_json(json_file)
      return json_file if json_file.is_a?(Hash)
      content = if json_file.respond_to?(:read)
                  json_file.read
                elsif json_file.respond_to?(:path)
                  File.read(json_file.path)
                end
      JSON.parse(content)
    rescue
      nil
    end
  end
end
