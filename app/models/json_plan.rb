# == Schema Information
#
# Table name: json_plans
#
#  id                     :bigint(8)        not null, primary key
#  data                   :jsonb
#  research_outputs_uuids :string           default([]), is an Array
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  dmp_id                 :string
#  plan_id                :bigint(8)        not null
#
# Indexes
#
#  idx_json_plans_data_gin      (data) USING gin
#  index_json_plans_on_dmp_id   (dmp_id)
#  index_json_plans_on_plan_id  (plan_id)
#
# Foreign Keys
#
#  fk_rails_...  (plan_id => plans.id)
#
class JsonPlan < ApplicationRecord
  belongs_to :plan
end
