# Static page class
class StaticPage < ActiveRecord::Base
  has_many :static_page_contents, dependent: :destroy
  accepts_nested_attributes_for :static_page_contents, allow_destroy: true

  validates :name, :url, presence: true, uniqueness: true

  alias contents static_page_contents

  # Get Static Page content for specified locale
  # @param locale requested locale for page content
  # @return [String] the localized Static Page Content
  def content(locale)
    spc = contents.find_by(language: Language.find_by(abbreviation: locale))

    return spc.content if spc
    nil
  end

  # Build Static Page content for languages
  # @return [StaticPage] the Static Page with it's contents builded
  def build_contents
    Language.all.each do |l|
      contents.new(language: l) unless content(l.abbreviation)
    end
    save unless new_record?
  end
end
