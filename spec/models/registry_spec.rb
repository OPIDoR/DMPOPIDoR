# == Schema Information
#
# Table name: registries
#
#  id          :integer          not null, primary key
#  category    :string
#  data_types  :string           default(["none"]), not null, is an Array
#  description :string
#  name        :string           not null
#  topics      :string           default(["generic"]), not null, is an Array
#  uri         :string
#  values      :json
#  version     :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  org_id      :integer
#
# Indexes
#
#  index_registries_on_org_id  (org_id)
#
# Foreign Keys
#
#  fk_rails_...  (org_id => orgs.id)
#
require 'rails_helper'

RSpec.describe Registry, type: :model do
  describe 'associations' do
    it { should belong_to(:org).optional }
  end

  describe 'validations' do
    subject { build(:registry) }

    it { should validate_presence_of(:name).with_message(ValidationMessages::PRESENCE_MESSAGE) }
    it { should validate_presence_of(:data_types).with_message(ValidationMessages::PRESENCE_MESSAGE) }
    it { should validate_presence_of(:topics).with_message(ValidationMessages::PRESENCE_MESSAGE) }
  end

  describe 'scopes' do
    let!(:registry1) { create(:registry, name: 'OpenAIRE', description: 'European repository', category: 'repository') }
    let!(:registry2) { create(:registry, name: 'Zenodo', description: 'Open science', category: 'archive') }

    describe '.search' do
      it 'returns registries matching name, description or category' do
        expect(Registry.search('open')).to include(registry1, registry2)
        expect(Registry.search('repository')).to include(registry1)
        expect(Registry.search('archive')).to include(registry2)
      end

      it 'is case insensitive' do
        expect(Registry.search('ZENODO')).to include(registry2)
      end
    end

    describe '.paginable' do
      it 'selects only specific fields' do
        result = Registry.paginable.first
        expect(result.attributes.keys).to include('id', 'name', 'version', 'description', 'uri', 'category',
                                                  'data_types', 'topics')
      end
    end
  end

  describe '.load_values' do
    let(:registry) { create(:registry, name: 'TestRegistry', values: nil) }

    context 'when file is nil' do
      it 'returns :no_file' do
        result = Registry.load_values(nil, registry)
        expect(result).to eq(:no_file)
      end
    end

    context 'when file responds to :read and contains valid JSON with matching key' do
      let(:file) { StringIO.new({ 'TestRegistry' => { 'key' => 'value' } }.to_json) }

      it 'updates registry values and returns :success' do
        result = Registry.load_values(file, registry)
        expect(result).to eq(:success)
        expect(registry.reload.values).to eq({ 'key' => 'value' })
      end
    end

    context 'when file responds to :read and contains valid JSON without matching key' do
      let(:file) { StringIO.new({ 'OtherRegistry' => {} }.to_json) }

      it 'does not update values and returns :wrong_format' do
        result = Registry.load_values(file, registry)
        expect(result).to eq(:wrong_format)
        expect(registry.reload.values).to be_nil
      end
    end

    context 'when file responds to :read and contains invalid JSON' do
      let(:file) { StringIO.new('not a json') }

      it 'returns :invalid_json' do
        result = Registry.load_values(file, registry)
        expect(result).to eq(:invalid_json)
        expect(registry.reload.values).to be_nil
      end
    end

    context 'when file responds to :path' do
      let(:tempfile) do
        Tempfile.new.tap do |f|
          f.write({ 'TestRegistry' => { 'key' => 'value' } }.to_json)
          f.rewind
        end
      end

      it 'reads from path and returns :success' do
        result = Registry.load_values(tempfile, registry)
        expect(result).to eq(:success)
        expect(registry.reload.values).to eq({ 'key' => 'value' })
      end
    end

    context 'when file responds to neither :read nor :path' do
      let(:bad_file) { Object.new }

      it 'logs error and returns :bad_file' do
        expect(Rails.logger).to receive(:error).with(/Bad values_file/)
        result = Registry.load_values(bad_file, registry)
        expect(result).to eq(:bad_file)
      end
    end
  end
end
