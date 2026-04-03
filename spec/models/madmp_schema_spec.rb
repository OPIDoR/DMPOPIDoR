# frozen_string_literal: true

# == Schema Information
#
# Table name: madmp_schemas
#
#  id            :integer          not null, primary key
#  classname     :string
#  data_type     :string           default("none"), not null
#  label         :string
#  name          :string
#  schema        :json
#  topics        :string           default(["generic"]), not null, is an Array
#  version       :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  api_client_id :bigint(8)
#  org_id        :integer
#
# Indexes
#
#  index_madmp_schemas_on_api_client_id  (api_client_id)
#  index_madmp_schemas_on_org_id         (org_id)
#
# Foreign Keys
#
#  fk_rails_...  (api_client_id => api_clients.id)
#  fk_rails_...  (org_id => orgs.id)
#
require 'rails_helper'

RSpec.describe MadmpSchema, type: :model do
  describe 'associations' do
    it { should belong_to(:org).optional }
    it { should belong_to(:api_client).optional }
    it { should have_many(:madmp_fragments) }
    it { should have_many(:questions) }
  end

  describe 'validations' do
    subject { build(:madmp_schema) } # Assure que la validation d’unicité fonctionne

    it { should validate_presence_of(:name).with_message(ValidationMessages::PRESENCE_MESSAGE) }
    it { should validate_uniqueness_of(:name).with_message(ValidationMessages::UNIQUENESS_MESSAGE) }
    it { should validate_presence_of(:data_type).with_message(ValidationMessages::PRESENCE_MESSAGE) }
    it { should validate_presence_of(:topics).with_message(ValidationMessages::PRESENCE_MESSAGE) }
  end

  describe 'scopes' do
    describe '.search' do
      let!(:schema1) { create(:madmp_schema, name: 'Data Management') }
      let!(:schema2) { create(:madmp_schema, classname: 'data_collection') }

      it 'returns matching records by name or classname' do
        expect(MadmpSchema.search('data')).to include(schema1, schema2)
      end

      it 'is case insensitive' do
        expect(MadmpSchema.search('DATA')).to include(schema1, schema2)
      end
    end

    describe '.paginable' do
      let!(:schema) { create(:madmp_schema) }

      it 'selects only specific fields' do
        expect(MadmpSchema.paginable.first.attributes.keys).to include('id', 'label', 'name', 'classname', 'topics',
                                                                       'api_client_id', 'version')
      end
    end
  end

  describe 'instance methods' do
    let(:schema_json) do
      {
        'description' => 'Test schema',
        'properties' => {
          'title' => { 'type' => 'string' },
          'author' => { 'type' => 'string', 'overridable' => true }
        },
        'default' => { 'en' => { 'title' => 'Default Title' } },
        'run' => [{ 'name' => 'script1', 'param' => 'value' }]
      }
    end

    let(:schema) { build(:madmp_schema, label: 'Label', name: 'Name', version: 2, schema: schema_json) }

    it '#detailed_name returns formatted string' do
      expect(schema.detailed_name).to eq('Label ( Name_V2 )')
    end

    it '#description returns schema description' do
      expect(schema.description).to eq('Test schema')
    end

    it '#properties returns schema properties' do
      expect(schema.properties.keys).to include('title', 'author')
    end

    it '#defaults returns default values for locale' do
      expect(schema.defaults('en')).to eq({ 'title' => 'Default Title' })
    end

    it '#run_parameters? returns true if run exists' do
      expect(schema.run_parameters?).to be true
    end

    it '#extract_run_parameters returns specific script params' do
      expect(schema.extract_run_parameters(script_name: 'script1')).to eq({ 'name' => 'script1', 'param' => 'value' })
    end

    it '#property_name_from_classname maps classname to property' do
      schema.classname = 'data_collection'
      expect(schema.property_name_from_classname).to eq('dataCollection')
    end
  end

  describe 'class methods' do
    describe '.serialize_json_response' do
      let(:api_client) { create(:api_client, name: 'ClientX') }
      let(:schema) { create(:madmp_schema, api_client: api_client) }

      it 'returns serialized hash' do
        result = MadmpSchema.serialize_json_response(schema)
        expect(result[:id]).to eq(schema.id)
        expect(result[:api_client][:name]).to eq('ClientX')
      end
    end

    describe '.suggest' do
      let!(:schema) { create(:madmp_schema, classname: 'legal_issues', data_type: 'typeA', topics: ['privacy']) }

      it 'returns matching schema' do
        expect(MadmpSchema.suggest('legal_issues', 'typeA', 'privacy')).to eq(schema)
      end
    end
  end
end
