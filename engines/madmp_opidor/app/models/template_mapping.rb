# frozen_string_literal: true

# == Schema Information
#
# Table name: template_mapping
#
#  id         :integer          not null, primary key
#  type_mapping       :enum             not null, default(form)
#  source_id  :integer          not null, foreign key
#  target_id  :integer          nullable, foreign to
#  mapping    :json             not null
#  name       :string           not null
#  created_at :datetime         not not
#  updated_at :datetime         not not
#
# Foreign Keys
#
#  fk_rails_...  (source_id => templates.id)
#  fk_rails_...  (target_id => template.id)
#

require 'jsonpath'

class TemplateMapping < ApplicationRecord
  belongs_to :source, class_name: 'Template', foreign_key: 'source_id'
  belongs_to :target, class_name: 'Template', foreign_key: 'target_id', optional: true
  enum type_mapping: { form: 0, json: 1 }

  validates :target_id, presence: true, if: :is_form?
  validates :name, presence: true

  def is_form?
    type_mapping == 'form'
  end

  def apply_mapping(json_dmp, question_id)
    regex = %r{<samp json-path="([^"]*)"></samp>}mi

    mapping[question_id].to_s.gsub(regex) do |match|
      path = Regexp.last_match(1)
      result = JsonPath.new(path).on(json_dmp).first
      result || ''
    end
  end
end
