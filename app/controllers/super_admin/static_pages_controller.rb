module SuperAdmin
  class StaticPagesController < ApplicationController
    before_action :set_static_page, only: %i[show edit update destroy]
    before_action :set_static_pages, only: :index

    # GET /static_pages
    # GET /static_pages.json
    def index
      authorize(StaticPage)
      render(:index, locals: { static_pages: @static_pages.page(1) })
    end

    # GET /static_pages/new
    def new
      authorize(StaticPage)
      @static_page = StaticPage.new

      Language.all.each do |l|
        @static_page.contents.new(language: l)
      end
    end

    # GET /static_pages/1/edit
    def edit
      authorize(StaticPage)
    end

    # POST /static_pages
    # POST /static_pages.json
    def create
      authorize(StaticPage)

      begin
        @static_page = StaticPage.create!(static_page_params)
        flash[:notice] = _('Static Page created successfully')
      rescue ActionController::ParameterMissing
        flash[:alert] = _('Unable to save since static_page parameter is missing')
      rescue ActiveRecord::RecordInvalid => e
        flash[:alert] = e.message
      end

      redirect_to action: :index
    end

    # PATCH/PUT /static_pages/1
    # PATCH/PUT /static_pages/1.json
    def update
      authorize(StaticPage)

      begin
        @static_page.update!(static_page_params)
        flash[:notice] = _('Static Page updated successfully')
      rescue ActionController::ParameterMissing
        flash[:alert] = _('Unable to save since static_page parameter is missing')
      rescue ActiveRecord::RecordInvalid => e
        flash[:alert] = e.message
      end

      redirect_to action: :index
    end

    # DELETE /static_pages/1
    # DELETE /static_pages/1.json
    def destroy
      @static_page.destroy
      respond_to do |format|
        format.html { redirect_to static_pages_url, notice: 'Static page was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_static_page
      @static_page = StaticPage.find(params[:id])
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_static_pages
      @static_pages = StaticPage.all
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def static_page_params
      params.require(:static_page).permit(
        :name,
        :url,
        static_page_contents_attributes: [%i[id language_id content]]
      )
    end
  end
end
