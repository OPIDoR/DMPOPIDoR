# frozen_string_literal: true

class MadmpCodebaseController < ApplicationController

  after_action :verify_authorized

  def run
    fragment = MadmpFragment.find(params[:fragment_id])
    script_id = params[:script_id]
    response = fetch_run_data(fragment, script_id)
    # fragment.save_codebase_fragment(response.data, fragment.madmp_schema)

    # EXAMPLE DATA : CODEBASE NEEDS FIXES
    # file_path = Rails.root.join("config/schemas/codebase_example_data.json")
    # response = JSON.load(File.open(file_path))
    # @fragment.save_codebase_fragment(response, @fragment.madmp_schema)

    authorize fragment
    render json: response.to_json
  end

  private

  def fetch_run_data(fragment, script_id)
    return {} unless fragment.present? && script_id.present?

    ExternalApis::MadmpCodebaseService.run(script_id, body:
      {
        "data": fragment.data,
        "schema": {},
        "dmp_id": fragment.dmp_id
      })
  end

end