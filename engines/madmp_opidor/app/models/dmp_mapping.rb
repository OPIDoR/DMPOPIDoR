# frozen_string_literal: true

# == Schema Information
#
# Table name: dmp_mapping
#
#  id         :integer          not null, primary key
#  type_mapping       :enum             not null, default(form)
#  source_id  :integer          not null, foreign key
#  target_id  :integer          nullable, foreign key
#  mapping    :json             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Foreign Keys
#
#  fk_rails_...  (source_id => templates.id)
#  fk_rails_...  (target_id => template.id)
#

class DmpMapping < ApplicationRecord
  belongs_to :source, class_name: 'Template', foreign_key: 'source_id'
  belongs_to :target, class_name: 'Template', foreign_key: 'target_id', optional: true
  enum type_mapping: { form: 0, json: 1 }

  validates :target_id, presence: true, if: :is_form?
  validates :mapping, presence: true

  def is_form?
    type_mapping == 'form'
  end
end

# class DmpMapping < ApplicationRecord
#   belongs_to :source, class_name: 'Template', foreign_key: 'source_id'
#   belongs_to :target, class_name: 'Template', foreign_key: 'target_id', optional: true
#   enum type_mapping: { form: 0, json: 1 }

#   validates :target_id, presence: true, if: :is_form?
#   validates :mapping, presence: true
# end
