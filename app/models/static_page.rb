# Static page class
class StaticPage < ActiveRecord::Base
  has_many :static_page_contents, dependent: :destroy
  accepts_nested_attributes_for :static_page_contents, allow_destroy: true

  validates :name, :url, presence: true, uniqueness: true

  alias contents static_page_contents
end
