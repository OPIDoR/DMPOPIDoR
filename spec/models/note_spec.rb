# frozen_string_literal: true

# == Schema Information
#
# Table name: notes
#
#  id          :integer          not null, primary key
#  archived    :boolean          default(FALSE), not null
#  archived_by :integer
#  text        :text
#  created_at  :datetime
#  updated_at  :datetime
#  answer_id   :integer
#  user_id     :integer
#
# Indexes
#
#  notes_answer_id_idx  (answer_id)
#  notes_user_id_idx    (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (answer_id => answers.id)
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe Note, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:text) }

    it { is_expected.to validate_presence_of(:answer) }

    it { is_expected.to validate_presence_of(:user) }

    it { is_expected.to allow_values(true, false).for(:archived) }

    it { is_expected.not_to allow_value(nil).for(:archived) }
  end

  context 'associations' do
    it { is_expected.to belong_to :answer }

    it { is_expected.to belong_to :user }
  end
end
