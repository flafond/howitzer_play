require_relative 'searchable_page'

class ElectronicsPage < WebPage
  URL = '/search/ela'
  validates :title, pattern: /\Aalbuquerque electronics.*- craigslist\z/

  include SearchablePage
end
