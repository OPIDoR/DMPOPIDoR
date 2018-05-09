# Static page class
class StaticPage < ActiveRecord::Base
  has_many :static_page_contents

  validates :name, :url, presence: true, uniqueness: true
end
