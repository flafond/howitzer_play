class HomePage < WebPage
  URL = '/'
  validates :title, pattern: /\Acraigslist: albuquerque jobs, apartments/
end