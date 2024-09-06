# frozen_string_literal: true

module Dmpopidor
  # Customized code for PublicPagesController
  module PublicPagesController
    # GET template_index
    # -----------------------------------------------------
    # Every publised template is displayed in the Templates Public pages
    # the templates are sorted by org name
    # rubocop:disable Metrics/AbcSize
    def template_index
      @templates_query_params = {
        page: paginable_params.fetch(:page, 1),
        search: paginable_params.fetch(:search, ''),
        sort_field: paginable_params.fetch(:sort_field, 'templates.title'),
        sort_direction: paginable_params.fetch(:sort_direction, 'asc')
      }

      templates = ::Template.live(::Template.families(::Org.all.pluck(:id)).pluck(:family_id))
                            .pluck(:id) <<
                  ::Template.where(is_default: true).unarchived.published.pluck(:id)
      @templates = ::Template.includes(:org)
                             .where(id: templates.uniq.flatten)
                             .unarchived.published.order('orgs.name asc').page(1)
    end

    def guidance_group_index
      @guidance_groups_query_params = {
        page: paginable_params.fetch(:page, 1),
        search: paginable_params.fetch(:search, ''),
        sort_field: paginable_params.fetch(:sort_field, 'guidance_groups.name'),
        sort_direction: paginable_params.fetch(:sort_direction, 'asc')
      }

      guidance_groups =  GuidanceGroup.where(published: true).pluck(:id)

      @guidance_groups = ::GuidanceGroup.includes(:org)
                                        .where(id: guidance_groups.uniq.flatten).order('orgs.name asc').page(1)
    end

    def guidance_group_export
      @guidance_group = GuidanceGroup.includes(guidances: :themes).find(params[:id])
      @formatting = Settings::Template::DEFAULT_SETTINGS[:formatting]
      html = render_to_string({
                                partial: 'branded/guidance_group_exports/guidance_group_export',
                                locals: { guidance_group: @guidance_group },
                                layout: false
                              })
      file_name = @guidance_group.name.gsub(/[^a-zA-Z\d\s]/, '').tr(' ', '_')
      respond_to do |format|
        format.html do
          pdf = Grover.new(html).to_pdf
          send_data(pdf, disposition: 'inline', filename: "#{file_name}.pdf",
                         type: 'application/pdf')
        end
      end
    end
    # rubocop:enable Metrics/AbcSize
  end
end
