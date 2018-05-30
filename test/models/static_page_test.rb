require 'test_helper'

class StaticPageTest < ActiveSupport::TestCase
  test 'valid' do
    assert(StaticPage.find_by(name: 'Help').valid?)
  end

  test 'content check' do
    path = "#{Rails.root}/public/help_default.html"
    sp = StaticPage.create(name: 'sp1', url: 'sp1')
    sp.contents.from_file(path)

    c1 = sp.contents.find_by(language: Language.default).content
    c2 = File.read(path)
    c3 = sp.content

    assert_equal(c1, c2)
    assert_equal(c3, c2)
  end

  test 'content initialization' do
    sp = StaticPage.create(name: 'sp2', url: 'sp2')

    assert_equal(Language.all.count, sp.contents.count)
  end
end
