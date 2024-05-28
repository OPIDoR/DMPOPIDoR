# frozen_string_literal: true

require 'jsonpath'

class DmpMappingController < ApplicationController
  include Dmpopidor::ErrorHelper
  respond_to :json

  def index
    mappings = DmpMapping::all

    render json: { status: 200, message: 'DMPOPDIoR mappings', data: mappings }
  end

  def show
    mapping = DmpMapping::where(id: params[:id]).first

    render json: { status: 200, message: "DMPOPDIoR mapping for [#{params[:id]}]", data: mapping }
  end

  def create
  end

  def edit
  end

  def update
  end

  def delete
  end
end
