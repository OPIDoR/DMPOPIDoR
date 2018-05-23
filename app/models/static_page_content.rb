class StaticPageContent < ActiveRecord::Base
  belongs_to :static_page
  belongs_to :language

  validates :language, uniqueness: { scope: :static_page_id }
end
