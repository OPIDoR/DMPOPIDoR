# frozen_string_literal: true

# Controller for the Public DMPs and Funder Requirements pages
class PublicPagesController < ApplicationController
  # --------------------------------
  # GET template_index
  # -----------------------------------------------------
  # CHANGES :
  #   - Every published template is displayed in the Templates Public pages
  #   - the templates are sorted by org name
  # rubocop:disable Metrics/AbcSize
  def template_index
    @templates_query_params = {
      page: paginable_params.fetch(:page, 1),
      search: paginable_params.fetch(:search, ''),
      sort_field: paginable_params.fetch(:sort_field, 'templates.title'),
      sort_direction: paginable_params.fetch(:sort_direction, 'asc')
    }

    templates = Template.live(Template.families(::Org.all.pluck(:id)).pluck(:family_id))
                        .pluck(:id) <<
                Template.where(is_default: true).unarchived.published.pluck(:id)
    @templates = Template.includes(:org)
                         .where(id: templates.uniq.flatten)
                         .unarchived.published.order('orgs.name asc')
  end
  # rubocop:enable Metrics/AbcSize

  # GET template_export/:id
  # -----------------------------------------------------
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def template_export
    # only export live templates, id passed is family_id
    @template = Template.live(params[:id])
    @modules = []
    # covers authorization for this action.
    # Pundit dosent support passing objects into scoped policies
    unless PublicPagePolicy.new(current_user, @template).template_export?
      msg = 'You are not authorized to export that template'
      redirect_to public_templates_path, notice: msg and return
      # raise Pundit::NotAuthorizedError
    end

    # now with prefetching (if guidance is added, prefetch annottaions/guidance)
    @template = Template.includes(
      :org,
      phases: {
        sections: {
          questions: %i[
            question_options
            question_format
            annotations
          ]
        }
      }
    ).find(@template.id)
    if @template.structured?
      @modules_tplt = Template.includes(
        :org,
        phases: {
          sections: {
            questions: %i[
              question_options
              question_format
              annotations
            ]
          }
        }
      ).where(published: true, archived: false, type: 'module', locale: @template.locale)
    end
    @formatting = Settings::Template::DEFAULT_SETTINGS[:formatting]

    begin
      file_name = @template.title.gsub(/[^a-zA-Z\d\s]/, '').tr(' ', '_')
      file_name = "#{file_name}_v#{@template.version}"
      respond_to do |format|
        format.docx do
          render docx: 'template_exports/template_export', filename: "#{file_name}.docx"
        end

        format.pdf do
          render pdf: file_name,
                 template: 'template_exports/template_export',
                 margin: @formatting[:margin],
                 footer: {
                   center: format(_('Template created using the %{application_name} service. Last modified %{date}'),
                                  application_name: ApplicationService.application_name,
                                  date: l(@template.updated_at.to_date, formats: :short)),
                   font_size: 8,
                   spacing: (@formatting[:margin][:bottom] / 2) - 4,
                   right: '[page] of [topage]',
                   encoding: 'utf8'
                 }
        end
      end
    rescue ActiveRecord::RecordInvalid
      # What scenario is this triggered in? it's common to our export pages
      redirect_to public_templates_path,
                  alert: _('Unable to download the DMP Template at this time.')
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  # GET /plans_index
  # ------------------------------------------------------------------------------------
  def plan_index
    @plans = Plan.publicly_visible.includes(:template)
    render 'plan_index', locals: {
      query_params: {
        page: paginable_params.fetch(:page, 1),
        search: paginable_params.fetch(:search, ''),
        sort_field: paginable_params.fetch(:sort_field, 'plans.updated_at'),
        sort_direction: paginable_params.fetch(:sort_direction, 'desc')
      }
    }
  end

  def guidance_group_index
    @guidance_groups_query_params = {
      page: paginable_params.fetch(:page, 1),
      search: paginable_params.fetch(:search, ''),
      sort_field: paginable_params.fetch(:sort_field, 'guidance_groups.name'),
      sort_direction: paginable_params.fetch(:sort_direction, 'asc')
    }

    guidance_groups =  ::GuidanceGroup.where(published: true).pluck(:id)

    @guidance_groups = ::GuidanceGroup.includes(:org)
                                      .where(id: guidance_groups.uniq.flatten).order('orgs.name asc')
  end

  # rubocop:disable Metrics/AbcSize
  def guidance_group_export
    @guidance_group = ::GuidanceGroup.includes(guidances: :themes).find(params[:id])
    @guidances = @guidance_group.guidances.joins(:themes).where(published: true)
    @themes = Theme.all.order(:number)
    @formatting = Settings::Template::DEFAULT_SETTINGS[:formatting]
    file_name = @guidance_group.name.gsub(/[^a-zA-Z\d\s]/, '').tr(' ', '_')
    respond_to do |format|
      format.pdf do
        # rubocop:disable Layout/LineLength
        render pdf: file_name,
               template: 'guidance_group_exports/guidance_group_export',
               margin: @formatting[:margin],
               footer: {
                 center: format(_('Guidance group created using the %{application_name} service. Last modified %{date}'), application_name: ApplicationService.application_name, date: l(@guidance_group.updated_at.to_date, formats: :short)),
                 font_size: 8,
                 spacing: (@formatting[:margin][:bottom] / 2) - 4,
                 right: '[page] of [topage]',
                 encoding: 'utf8'
               }
        # rubocop:enable Layout/LineLength
      end
    end
  end
  # rubocop:enable Metrics/AbcSize

  private

  def paginable_params
    params.permit(:page, :search, :sort_field, :sort_direction)
  end
end
