# frozen_string_literal: true

module Import
  class Plan
    def import(plan, import_params, current_user)
      import_format = import_params[:format].eql?('null') ? 'standard' : import_params[:format]
      ::Plan.transaction do
        recommended_template = ::Template.recommend(context: import_params[:context],
                                                    locale: import_params[:locale]) || ::Template.default
        plan.template = recommended_template

        # pre-select org's guidance and the default org's guidance
        ids = (::Org.default_orgs.pluck(:id) << current_user.org_id).flatten.uniq

        language = Language.find_by(abbreviation: plan.template.locale)

        ggs = ::GuidanceGroup.where(org_id: ids, optional_subset: false, published: true, language_id: language.id)

        plan.guidance_groups << ggs unless ggs.empty?

        json_file = import_params[:json_file]
        if json_file.respond_to?(:read)
          json_data = JSON.parse(json_file.read)
        elsif json_file.respond_to?(:path)
          json_data = JSON.parse(File.read(json_file.path))
        else
          raise IOError, _('Unvalid file')
        end

        errs = Import::PlanImportService.validate(json_data, import_format, locale: plan.template.locale)

        raise StandardError, errs if errs.any?

        plan.visibility = Rails.configuration.x.plans.default_visibility

        plan.title = format(_("%{user_name}'s Plan"), user_name: current_user.firstname)
        plan.org = current_user.org

        raise StandardError, _('Unable to create plan.') unless plan.save!

        plan_title = format(_('Import of %{title}'), title: json_data.dig('meta', 'title'))
        plan.add_user!(current_user.id, :creator)
        plan.save
        plan.create_plan_fragments(json_data)

        json_data['meta']['title'] = plan_title

        Import::PlanImportService.import(plan, json_data, import_format)

        plan.update(title: plan_title)

        { planId: plan.id }
      end
    end
  end
end
