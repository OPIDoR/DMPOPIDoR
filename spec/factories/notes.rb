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
#  fk_rails_...  (answer_id => answers.id) DEFERRABLE INITIALLY DEFERRED
#  fk_rails_...  (user_id => users.id) DEFERRABLE INITIALLY DEFERRED
#

FactoryBot.define do
  factory :note do
    user
    text { Faker::Lorem.sentence }
    answer
    archived { false }
  end
end
