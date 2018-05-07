class StaticPageContent < ActiveRecord::Base
  belongs_to :static_page
  belongs_to :language
end
