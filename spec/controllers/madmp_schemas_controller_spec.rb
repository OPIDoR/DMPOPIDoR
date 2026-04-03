# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MadmpSchemasController, type: :controller do
  before(:each) do
    @user = create(:user)
    @schema = create(:madmp_schema, name: 'legal_issues', data_type: 'typeA', topics: ['privacy'],
                                    classname: 'legal_issues')

    @controller = described_class.new
    sign_in(@user)
  end

  describe 'GET #index' do
    before { @schema }

    it 'returns matching schemas with selected fields' do
      get :index, params: { data_type: 'typeA', topic: 'privacy', classname: 'legal_issues' }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.first.keys).to contain_exactly('id', 'name', 'label', 'schema')
      expect(json.first['name']).to eq('legal_issues')
    end

    it 'defaults to topic=standard and data_type=none if not provided' do
      get :index, params: { classname: 'legal_issues' }
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET #show' do
    it 'returns serialized schema' do
      get :show, params: { id: @schema.id }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['name']).to eq('legal_issues')
    end
  end

  describe 'GET #by_name' do
    context 'when schema exists' do
      it 'returns serialized schema' do
        get :by_name, params: { name: 'legal_issues' }
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['name']).to eq('legal_issues')
      end
    end

    context 'when schema does not exist' do
      it 'returns 404 with error message' do
        get :by_name, params: { name: 'unknown_schema' }
        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json['message']).to include('form is unavailable')
      end
    end
  end
end
