# == Schema Information
#
# Table name: registry_values
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  description       :string
#  uri        :string
#  version    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  org_id :integer
#

class Registry < ActiveRecord::Base
  include ValidationMessages

  # ================
  # = Associations =
  # ================

  has_many :registry_values, dependent: :destroy

  belongs_to :org

  # ===============
  # = Validations =
  # ===============

  validates :name, presence: { message: PRESENCE_MESSAGE }

end