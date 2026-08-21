# frozen_string_literal: true

# == Schema Information
#
# Table name: comment_read_marks
#
#  id           :bigint(8)        not null, primary key
#  last_read_at :datetime         not null
#  answer_id    :bigint(8)        not null
#  user_id      :bigint(8)        not null
#
# Indexes
#
#  index_comment_read_marks_on_answer_id              (answer_id)
#  index_comment_read_marks_on_user_id                (user_id)
#  index_comment_read_marks_on_user_id_and_answer_id  (user_id,answer_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (answer_id => answers.id)
#  fk_rails_...  (user_id => users.id)
#

# Object that represents an Answer to a Plan question
class CommentReadMark < ApplicationRecord
  # ================
  # = Associations =
  # ================
  belongs_to :user

  belongs_to :answer
end
