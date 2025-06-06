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

# Object that represents a comment on a Plan
class Note < ApplicationRecord
  # ================
  # = Associations =
  # ================

  belongs_to :answer

  belongs_to :user

  # ===============
  # = Validations =
  # ===============

  validates :text, presence: { message: PRESENCE_MESSAGE }

  validates :answer, presence: { message: PRESENCE_MESSAGE }

  validates :user, presence: { message: PRESENCE_MESSAGE }

  validates :archived, inclusion: { in: BOOLEAN_VALUES,
                                    message: INCLUSION_MESSAGE }
end
