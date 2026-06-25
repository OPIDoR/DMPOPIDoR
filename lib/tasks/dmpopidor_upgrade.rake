# frozen_string_literal: true

# rubocop:disable Naming/VariableNumber
namespace :dmpopidor_upgrade do
  desc 'Upgrade to 4.4.1'
  task V4_4_1: :environment do
    Rake::Task['dmpopidor_upgrade:generate_public_json_plans'].execute
    Rake::Task['dmpopidor_upgrade:generate_structured_json_plans'].execute
  end
  desc 'Upgrade to 4.4.0'
  task V4_4_0: :environment do
    Rake::Task['dmpopidor_upgrade:migrate_context_to_plans'].execute
    Rake::Task['dmpopidor_upgrade:migrate_template_context_to_contexts'].execute
    Rake::Task['dmpopidor_upgrade:migrate_guidance_groups_to_research_outputs'].execute
    Rake::Task['dmpopidor_upgrade:migrate_software_roles_registry_values'].execute
    Rake::Task['dmpopidor_upgrade:migrate_software_roles_registry_all_roles_values'].execute
    Rake::Task['dmpopidor_upgrade:migrate_default_data_type_values'].execute
    Rake::Task['dmpopidor_upgrade:migrate_research_outputs_data_type'].execute
  end
  desc 'Upgrade to 4.3.7'
  task V4_3_7: :environment do
    Rake::Task['data_migration:V4_3_7'].execute
  end
  desc 'Upgrade to 4.3.4'
  task V4_3_4: :environment do
    Rake::Task['data_migration:V4_3_4'].execute
  end
  desc 'Upgrade to 4.3.0'
  task V4_3_0: :environment do
    Rake::Task['dmpopidor_upgrade:add_default_data_type_to_research_outputs'].execute
    Rake::Task['dmpopidor_upgrade:add_default_type_to_research_outputs_without_type'].execute
    Rake::Task['data_migration:V4_3_0'].execute
  end
  desc 'Upgrade to 4.2.0'
  task V4_2_0: :environment do
    Rake::Task['dmpopidor_upgrade:add_default_language_to_guidance_groups'].execute
  end
  desc 'Upgrade to 2.1.0'
  task v2_1_0: :environment do
    Rake::Task['dmpopidor_upgrade:add_themes_token_permission_types'].execute
    Rake::Task['dmpopidor_upgrade:grant_themes_api_to_all_orgs'].execute
    Rake::Task['dmpopidor_upgrade:grant_api_to_all_orgs'].execute
    Rake::Task['dmpopidor_upgrade:create_number_field'].execute
  end

  desc 'Upgrade to 2.2.0'
  task v2_2_0: :environment do
    Rake::Task['dmpopidor_upgrade:create_research_output_types'].execute
    Rake::Task['dmpopidor_upgrade:research_outputs_enable'].execute
  end

  desc 'Upgrade to 2.3.0'
  task v2_3_0: :environment do
    Rake::Task['dmpopidor_upgrade:close_existing_feedback_plans'].execute
  end

  desc 'Generate JSONPlan record for public plans'
  task generate_public_json_plans: :environment do
    Plan.publicly_visible.each do |plan|
      p "########### Generating JSON plan for plan #{plan.id} ###########"
      JsonPlanJob.perform_now(plan_id: plan.id)
    end
  end

  desc 'Generate JSONPlan record for structured plans'
  task generate_structured_json_plans: :environment do
    Plan.includes(:template).where(template: { type: 'structured' }).each do |plan|
      next if JsonPlan.exists?(plan_id: plan.id)

      p "########### Generating JSON plan for plan #{plan.id} ###########"
      JsonPlanJob.perform_now(plan_id: plan.id)
    end
  end

  desc 'Migrate default data type values for guidance groups, registries, themes, templates and madmp schemas'
  task migrate_default_data_type_values: :environment do
    GuidanceGroup.where(Arel.sql("'none' = ANY(data_types)")).map do |gg|
      new_dt = gg.data_types.map { |dt| dt.eql?('none') ? 'dataset' : dt }
      gg.update_column(:data_types, new_dt)
    end
    Registry.where(Arel.sql("'none' = ANY(data_types)")).map do |r|
      new_dt = r.data_types.map { |dt| dt.eql?('none') ? 'dataset' : dt }
      r.update_column(:data_types, new_dt)
    end
    Theme.where(data_type: 'none').update_all(data_type: 'dataset')
    Template.where(data_type: 'none').update_all(data_type: 'dataset')
    MadmpSchema.where(data_type: 'none').update_all(data_type: 'dataset')
  end

  desc 'Migrate research outputs with "none" data type to have "dataset" value'
  task migrate_research_outputs_data_type: :environment do
    Fragment::ResearchOutput.where(Arel.sql("additional_info->>'dataType' = 'none'")).map do |ro|
      new_ai = ro.additional_info.merge({ 'dataType' => 'dataset' })
      ro.update_column(:additional_info, new_ai)
    end
  end

  desc 'Migrate SoftwareRoles registry values in contributor fragments'
  task migrate_software_roles_registry_values: :environment do
    p "Migration contributors with 'Débogage' value"
    Fragment::Contributor.where("data ->> 'role' = 'Débogage'").each do |c|
      c.update_column(:data, c.data.merge({ 'role' => 'Debugging' })) if c.plan.template.locale.eql?('en-GB')
    end
    p "Migration contributors with 'Développement' value"
    Fragment::Contributor.where("data ->> 'role' = 'Développement'").each do |c|
      c.update_column(:data, c.data.merge({ 'role' => 'Coding' })) if c.plan.template.locale.eql?('en-GB')
    end
    p "Migration contributors with 'Test' value"
    Fragment::Contributor.where("data ->> 'role' = 'Test'").each do |c|
      c.update_column(:data, c.data.merge({ 'role' => 'Testing' })) if c.plan.template.locale.eql?('en-GB')
    end
  end
  desc 'Migrate SoftwareRoles registry values in contributor fragments with "Tous les roles"'
  task migrate_software_roles_registry_all_roles_values: :environment do
    p "Migration contributors with 'Tous les roles' value"
    fr_roles = %w[Conception Débogage Développement Documentation Maintenance Management Support Test]
    en_roles = %w[Conception Debugging Coding Documentation Maintenance Management Support Testing]
    Fragment::Contributor.where("data ->> 'role' = 'Architecture, Conception, Débogage, Développement, Documentation, Maintenance, Management, Support, Test'").each do |c| # rubocop:disable Layout/LineLength
      c.update_column(:data, c.data.merge({ 'role' => 'Architecture' }))
      c_data = c.data
      if c.plan.template.locale.eql?('en-GB')
        en_roles.each do |r|
          dupped = c.dup
          dupped.data = c_data.merge({ 'role' => r })
          dupped.save!
        end
      else
        fr_roles.each do |r|
          dupped = c.dup
          dupped.data = c_data.merge({ 'role' => r })
          dupped.save!
        end
      end
    end
  end

  desc 'Migrate guidance groups from plans to research_outputs in structured plans'
  task migrate_guidance_groups_to_research_outputs: :environment do
    Plan.includes(:template, :research_outputs, :guidance_groups).all.each do |plan|
      next unless plan.structured?

      p "Migrating guidance groups for plan #{plan.id}"
      plan.research_outputs.each do |ro|
        ro.guidance_groups << plan.guidance_groups.all
      end
      plan.guidance_groups.destroy_all
    end
  end

  desc 'Migrate from templates.context to template.contexts'
  task migrate_template_context_to_contexts: :environment do
    Template.all.each do |template|
      p "Migrating template #{template.id}"
      template.update_column(:contexts, [template.context.eql?(0) ? 'research_project' : 'research_entity'])
    end
  end

  desc 'Migrate context from templates to plans'
  task migrate_context_to_plans: :environment do
    Plan.includes(:template).all.each do |plan|
      p "Migrating plan #{plan.id}"
      plan.update_column(:context, plan.template.context)
    end
  end

  desc 'Add default data_type to research outputs'
  task add_default_data_type_to_research_outputs: :environment do
    Fragment::ResearchOutput.all.each do |ro_fragment|
      next unless ro_fragment.additional_info['dataType'].nil?

      p "Updating research output fragment #{ro_fragment.id}"
      ro_fragment.update_column(
        :additional_info,
        ro_fragment.additional_info.merge({
                                            'moduleId' => nil,
                                            'dataType' => 'none'
                                          })
      )
    end
  end

  desc 'Add default type to research outputs withoyt type'
  task add_default_type_to_research_outputs_without_type: :environment do
    Fragment::ResearchOutputDescription.all.each do |rod_fragment|
      next if rod_fragment.data['type'].present?

      I18n.with_locale rod_fragment.plan.template.locale do
        rod_fragment.update_column(:data, rod_fragment.data.merge('type' => _('Dataset')))
      end
    end
  end

  desc 'Add default language to guidance groups'
  task add_default_language_to_guidance_groups: :environment do
    GuidanceGroup.where(language_id: 0).each do |gg|
      gg.update(language: Language.default)
    end
  end

  desc 'Add the themes token permission type'
  task add_themes_token_permission_types: :environment do
    if TokenPermissionType.find_by(token_type: 'themes').nil?
      TokenPermissionType.create!({ token_type: 'themes',
                                    text_description: 'allows a user access to the themes api endpoint' })
    end
  end

  desc 'Grant themes API to all orgs'
  task grant_themes_api_to_all_orgs: :environment do
    orgs = Org.where(is_other: false).select(:id) + Org.where(is_other: nil).select(:id)
    orgs.each do |org|
      org.grant_api!(TokenPermissionType.where(token_type: 'themes'))
    end
  end

  desc 'Grant all API to all orgs'
  task grant_api_to_all_orgs: :environment do
    orgs = Org.where(is_other: false).select(:id) + Org.where(is_other: nil).select(:id)
    orgs.each do |org|
      org.grant_api!(TokenPermissionType.where(token_type: 'guidances'))
      org.grant_api!(TokenPermissionType.where(token_type: 'plans'))
      org.grant_api!(TokenPermissionType.where(token_type: 'templates'))
      org.grant_api!(TokenPermissionType.where(token_type: 'statistics'))
    end
  end

  desc 'Create number field'
  task create_number_field: :environment do
    if QuestionFormat.find_by(title: 'Number').nil?
      QuestionFormat.create!({ title: 'Number', option_based: false, formattype: 8 })
    end
  end

  # Migrates the database to use research_outputs
  # - Adds a research output table to the base (via the above migrations)
  # - Creates a default research output for every plan
  # - Moves all plans' answers to their new default research output
  desc 'Migrate the database to use research outputs'
  task research_outputs_enable: :environment do
    # Apply migration

    # Create research outputs and move answers
    Plan.all.each do |p|
      research_output = if p.research_outputs.empty?
                          p.research_outputs.create(
                            abbreviation: "#{_('RO')} 1",
                            title: "#{_('Research output')} 1",
                            is_default: true,
                            type: ResearchOutputType.find_by(label: 'Dataset'),
                            order: 1
                          )
                        end

      p.answers.each { |a| a.update_column(:research_output_id, research_output.id) }
    end
  end

  # Rollback for the database migration enable the research outputs
  # - Remove all non default research outputs and their answers
  # - 'Detach' remaining answers from their research outputs (the default ones)
  # - Drop the research outputs table and reverse the migrations
  desc 'Migrate the database to remove research outputs'
  task research_outputs_disable: :environment do
    # Destroy all research outputs which are not defaut research outputs and their answers
    ResearchOutput.where(is_default: false).destroy_all
    Rake::Task['db:migrate:down VERSION=20190503130010'].execute
    Rake::Task['db:migrate:down VERSION=20190620120126'].execute
  end

  desc 'Create Research output types'
  task create_research_output_types: :environment do
    research_output_types = [
      { label: 'Audiovisual' },
      { label: 'Collection' },
      { label: 'Dataset' },
      { label: 'Image' },
      { label: 'Interactive Resource' },
      { label: 'Model' },
      { label: 'Physical Object' },
      { label: 'Service' },
      { label: 'Software' },
      { label: 'Sound' },
      { label: 'Text' },
      { label: 'Workflow' },
      { label: 'Other', is_other: true }
    ]

    research_output_types.map { |s| ResearchOutputType.create!(s) if ResearchOutputType.find_by(label: s[:label]).nil? }
  end

  desc 'Set feedback_requested on existing plans to false'
  task close_existing_feedback_plans: :environment do
    Plan.where(feedback_requested: true).update_all(feedback_requested: false)
  end

  desc 'Add Structured question format in table'
  task add_structure_question_format: :environment do
    if QuestionFormat.find_by(title: 'Structured').nil?
      QuestionFormat.create!({ title: 'Structured', description: 'Structured question format',
                               option_based: false, formattype: 9, structured: true })
    end
  end
end
# rubocop:enable Naming/VariableNumber
