# frozen_string_literal: true

# == Schema Information
#
# Table name: madmp_fragments
#
#  id              :integer          not null, primary key
#  additional_info :json
#  classname       :string
#  data            :json
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  answer_id       :integer
#  dmp_id          :integer
#  madmp_schema_id :integer
#  parent_id       :integer
#
# Indexes
#
#  index_madmp_fragments_on_answer_id        (answer_id)
#  index_madmp_fragments_on_madmp_schema_id  (madmp_schema_id)
#
# Foreign Keys
#
#  fk_rails_...  (answer_id => answers.id)
#  fk_rails_...  (madmp_schema_id => madmp_schemas.id)
#
require 'rails_helper'

RSpec.describe MadmpFragment, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:madmp_schema) }
  end

  context 'associations' do
    it { is_expected.to belong_to :madmp_schema }

    it { is_expected.to belong_to :answer }
  end

  # describe ".update_parent_references" do

  #   it "should be called after a structured answer is created" do

  #     parent_answer = FactoryBot.create(:madmp_fragment, classname: "dmp")

  #     subject = Fragment::ResearchOutput.new

  #     subject.parent_id = parent_answer.id
  #     subject.dmp_id = parent_answer.id

  #     expect(subject).to receive(:update_parent_references)

  #     subject.save

  #   end
  # end
end
