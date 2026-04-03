# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MadmpFragmentsController, type: :controller do
  before(:each) do
    @plan = create(:plan, :creator)
    @user = @plan.owner
    @dmp = create(:dmp, plan: @plan)
    @schema = create(:madmp_schema)
    @research_output = create(:research_output, plan: @plan)
    @question = create(:question)

    @controller = described_class.new
    sign_in(@user)
  end

  describe 'POST #create' do
    before(:each) do
      @body = {
        dmp_id: @dmp.id,
        schema_id: @schema.id,
        research_output_id: @research_output.id,
        question_id: @question.id,
        data: {}
      }.to_json
    end

    it 'creates a new MadmpFragment' do
      expect do
        post :create, body: @body, as: :json
      end.to change(MadmpFragment, :count).by(1)
    end

    it 'returns a successful JSON response' do
      post :create, body: @body, as: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to include('fragment')
    end
  end

  describe 'GET #show' do
    before(:each) do
      @fragment = create(:madmp_fragment, madmp_schema: @schema)
    end

    it 'returns the fragment JSON' do
      get :show, params: { id: @fragment.id }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to include('fragment')
    end
  end

  describe 'PUT #update' do
    before(:each) do
      @fragment = create(:madmp_fragment, madmp_schema: @schema, dmp: @dmp)
      @form_data = { some_key: 'some_value' }.to_json
    end

    it 'updates the fragment and returns success' do
      put :update, params: { id: @fragment.id }, body: @form_data, as: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['message']).to eq('Form saved successfully.')
    end
  end

  describe 'GET #load_fragments' do
    before(:each) do
      @fragment = create(:madmp_fragment, dmp_id: @dmp.id, madmp_schema: @schema)
    end

    it 'returns matching fragments' do
      get :load_fragments, params: { dmp_id: @dmp.id, schema_id: @schema.id, term: @fragment.to_s }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to include('results')
    end
  end

  describe 'DELETE #destroy' do
    before(:each) do
      @fragment = create(:madmp_fragment)
    end

    it 'removes the fragment' do
      expect do
        delete :destroy, params: { id: @fragment.id }
      end.to change(MadmpFragment, :count).by(-1)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'DELETE #destroy_contributor' do
    before(:each) do
      @person = create(:person_fragment)
      @contributor = create(:contributor, person: @person)
    end

    it 'removes the contributor and person' do
      expect do
        delete :destroy_contributor, params: { contributor_id: @person.id }
      end.to change(Fragment::Person, :count).by(-1)
      expect(response).to have_http_status(:ok)
    end
  end
end
