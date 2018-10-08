class Dataset < ActiveRecord::Base
  belongs_to :plan
  has_many :answers, dependent: :destroy
end
