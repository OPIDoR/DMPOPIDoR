# frozen_string_literal: true

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
