# frozen_string_literal: true

# == Schema Information
#
# Table name: token_permission_types
#
#  id               :integer          not null, primary key
#  text_description :text
#  token_type       :string
#  created_at       :datetime
#  updated_at       :datetime
#
require 'rails_helper'

RSpec.describe TokenPermissionType, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:token_type) }
  end

  describe '#to_s' do
    let!(:token_permission_type) do
      build(:token_permission_type, token_type: 'templates')
    end

    subject { token_permission_type.to_s }

    it 'returns the token_type attribute' do
      expect(subject).to eql('templates')
    end
  end
end
