# frozen_string_literal: true

# == Schema Information
#
# Table name: research_outputs
#
#  id                      :integer          not null, primary key
#  abbreviation            :string
#  description             :text
#  display_order           :integer
#  is_default              :boolean          default(FALSE)
#  output_type             :integer          default("dataset"), not null
#  output_type_description :string
#  pid                     :string
#  title                   :string
#  topic                   :string           default("generic"), not null
#  uuid                    :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  plan_id                 :integer
#
# Indexes
#
#  index_research_outputs_on_plan_id  (plan_id)
#
# Foreign Keys
#
#  fk_rails_...  (plan_id => plans.id)
#
require 'rails_helper'

RSpec.describe ResearchOutput, type: :model do
  context 'associations' do
    it { is_expected.to belong_to(:plan) }
    it { is_expected.to have_many(:answers) }
    it { should have_and_belong_to_many(:guidance_groups) }
    it { should have_many(:guidances).through(:guidance_groups) }
    it { should have_many(:themes).through(:guidances) }
  end

  context 'validations' do
    before(:each) do
      @subject = create(:research_output, plan: create(:plan))
    end
    it { is_expected.to define_enum_for(:output_type).with_values(ResearchOutput.output_types.keys) }

    it { is_expected.to validate_presence_of(:plan) }
    it { is_expected.to validate_presence_of(:topic) }
    it { is_expected.to validate_presence_of(:output_type) }
    it { is_expected.to validate_presence_of(:title) }

    it {
      expect(@subject).to validate_uniqueness_of(:title).case_insensitive
                                                        .scoped_to(:plan_id)
                                                        .with_message('must be unique')
    }
    it {
      expect(@subject).to validate_uniqueness_of(:abbreviation).case_insensitive
                                                               .scoped_to(:plan_id)
                                                               .with_message('must be unique')
    }

    it "requires :output_type_description if :output_type is 'other'" do
      @subject.other!
      expect(@subject).to validate_presence_of(:output_type_description)
    end
    it "does not require :output_type_description if :output_type is 'dataset'" do
      @subject.dataset!
      expect(@subject).not_to validate_presence_of(:output_type_description)
    end
  end
  it 'factory builds a valid model' do
    expect(build(:research_output).valid?).to eql(true)
  end

  describe 'cascading deletes' do
    it 'does not delete associated plan' do
      model = create(:research_output, plan: create(:plan))
      plan = model.plan
      model.destroy
      expect(Plan.last).to eql(plan)
    end
  end

  describe '.main?' do
    let!(:research_output) { build(:research_output, display_order: 1) }

    subject { research_output.main? }

    context 'when display_order is equal to 1' do
      it { is_expected.to eql(true) }
    end

    context 'when display_order is not equal to 1' do
      before do
        research_output.update(display_order: 2)
      end
      it { is_expected.to eql(false) }
    end
  end

  describe '.main' do
    let!(:plan) { build(:plan) }
    let!(:main_research_output) { create(:research_output, plan: plan, display_order: 1) }
    let!(:subj_research_output) { create(:research_output, plan: plan, display_order: 2) }

    subject { subj_research_output.main }

    context 'return first research output' do
      it { is_expected.to eql(main_research_output) }
    end
  end

  describe '.generate_uuid!' do
    let!(:research_output) { create(:research_output, uuid: 'uuid') }

    subject { research_output.generate_uuid! }

    context 'uuid should have changed' do
      it { is_expected.to_not eql('uuid') }
    end
  end

  describe '.json_fragment' do
    let!(:plan) { create(:plan) }
    let!(:dmp_fragment) { create(:madmp_fragment, :dmp, data: { plan_id: plan.id }).becomes(Fragment::Dmp) }
    let!(:research_output) { create(:research_output, plan:) }
    let!(:research_output_fragment) do
      create(:madmp_fragment, :research_output, data: { research_output_id: research_output.id },
                                                parent: dmp_fragment, dmp: dmp_fragment).becomes(Fragment::ResearchOutput)
    end

    subject { research_output.json_fragment }

    context 'return the proper MadmpFragment' do
      it { is_expected.to eql(research_output_fragment) }
    end
  end
end
