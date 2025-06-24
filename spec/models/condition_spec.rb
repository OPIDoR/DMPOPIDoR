# frozen_string_literal: true

# == Schema Information
#
# Table name: conditions
#
#  id           :integer          not null, primary key
#  action_type  :integer
#  number       :integer
#  option_list  :text
#  remove_data  :text
#  webhook_data :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  question_id  :integer
#
# Indexes
#
#  index_conditions_on_question_id  (question_id)
#
# Foreign Keys
#
#  fk_rails_...  (question_id => questions.id)
#
require 'rails_helper'

RSpec.describe Condition, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
