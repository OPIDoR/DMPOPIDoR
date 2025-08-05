# frozen_string_literal: true

# == Schema Information
#
# Table name: madmp_schemas
#
#  id            :integer          not null, primary key
#  classname     :string
#  data_type     :string           default("none"), not null
#  label         :string
#  name          :string
#  schema        :json
#  topics        :string           default(["standard"]), not null, is an Array
#  version       :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  api_client_id :bigint(8)
#  org_id        :integer
#
# Indexes
#
#  index_madmp_schemas_on_api_client_id  (api_client_id)
#  index_madmp_schemas_on_org_id         (org_id)
#
# Foreign Keys
#
#  fk_rails_...  (api_client_id => api_clients.id)
#  fk_rails_...  (org_id => orgs.id)
#
require 'rails_helper'

RSpec.describe MadmpSchema, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
