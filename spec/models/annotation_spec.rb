# frozen_string_literal: true

# == Schema Information
#
# Table name: annotations
#
#  id             :integer          not null, primary key
#  text           :text
#  type           :integer          default(0), not null
#  created_at     :datetime
#  updated_at     :datetime
#  org_id         :integer
#  question_id    :integer
#  versionable_id :string(36)
#
# Indexes
#
#  annotations_org_id_idx               (org_id)
#  annotations_question_id_idx          (question_id)
#  index_annotations_on_versionable_id  (versionable_id)
#
# Foreign Keys
#
#  fk_rails_...  (org_id => orgs.id) DEFERRABLE INITIALLY DEFERRED
#  fk_rails_...  (question_id => questions.id) DEFERRABLE INITIALLY DEFERRED
#
require 'rails_helper'

RSpec.describe Annotation, type: :model do
  it_behaves_like 'VersionableModel'

  context 'validations' do
    subject { build(:annotation) }

    it { is_expected.to validate_presence_of(:text) }

    it { is_expected.to validate_presence_of(:org) }

    it { is_expected.to validate_presence_of(:question) }

    it { is_expected.to validate_presence_of(:type) }
  end

  describe '#to_s' do
    let!(:annotation) { build(:annotation) }

    subject { annotation.to_s }

    it { is_expected.to eql(annotation.text) }
  end

  describe '#deep_copy' do
    context 'when question_id option is nil' do
      before do
        @annotation = create(:annotation)
        @new_annotation = @annotation.deep_copy
      end

      it 'creates a different record' do
        expect(@new_annotation).not_to eql(@annotation)
      end

      it 'copies the text attribute' do
        expect(@new_annotation.text).to eql(@annotation.text)
      end

      it 'copies the type attribute' do
        expect(@new_annotation.type).to eql(@annotation.type)
      end

      it 'copies the org_id attribute' do
        expect(@new_annotation.org_id).to eql(@annotation.org_id)
      end

      it 'sets question_id to nil' do
        expect(@new_annotation.question_id).to be_nil
      end
    end

    context 'when question_id option is set' do
      before do
        @annotation = create(:annotation)
        args = { question_id: 1 }
        @new_annotation = @annotation.deep_copy(**args)
      end

      it 'sets question_id to nil' do
        expect(@new_annotation.question_id).to eql(1)
      end
    end
  end
end
