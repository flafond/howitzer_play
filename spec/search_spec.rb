require 'spec_helper'

BASE_SEARCH = 'speakers'

describe 'Searching Craigslist' do

  before(:example) do
    unless @base_count
      baseline_page = ElectronicsPage.open.search_for(search_text: BASE_SEARCH)
      @base_count = baseline_page.count
      @page1_items = baseline_page.items
    end
  end

  it 'can search by text only' do
    expect(@base_count).to be > 100 # There are always more than 100 speakers
  end

  it 'will find no results when min price > max price' do
    results = ElectronicsPage.open.search_for(min_price: 51.00, max_price: 50.00)
    expect(results.count).to equal 0
  end

  it 'will find more results when including nearby areas' do
    surrounding_area_count = ElectronicsPage.open.search_for(search_text: BASE_SEARCH, search_nearby: true).count
    expect(surrounding_area_count).to be > @base_count
  end

  it 'will find a subset of results when searching titles only' do
    title_only = ElectronicsPage.open.search_for(search_text: BASE_SEARCH, titles_only: true)
    expect(title_only.count).to be < @base_count
    expect(@page1_items).to include(title_only.items.first)
  end
end
