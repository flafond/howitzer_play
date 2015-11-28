require 'json'

##
#
# This module expects to be included in a WebPage
#
module SearchablePage

  def self.included(base)
    base.class_eval do

      add_field_locator :search_text,    'query'
      add_field_locator :min_price,      'min_price'
      add_field_locator :max_price,      'max_price'
      add_button_locator :search_button, 'search'

      {
        category:           '#catAbb',
        city:               '#areaAbb',
        has_image:          'hasPic',
        posted_today:       'postedToday',
        search_nearby:      'searchNearby',
        subcategory:        '#subcatAbb',
        titles_only:        'srchType',
        no_results_message: '.noresults',
        total:              '.totalcount',
        item:               '.row',
        item_name:          '.hdrlnk',
      }.each {|name, identifier| add_locator(name, identifier)}

      # Links
      {
        account:      'account',
        all_sellers:  'all',
        dealer_only:  'dealer',
        email_alert:  'email alert',
        list:         'list',
        private_only: 'owner',
        post:         'post',
        reset:        'reset',
        save_search:  'save search',
        # Many more...
      }.each { |name, identifier| add_link_locator(name, identifier)}
    end
  end

  # The verb_noun shortcuts

  def click_search() click_button button_locator(:search_button) end

  ##
  #
  # Is the no results message being displayed?
  #
  # *Returns:*
  # * +Boolean+ - false if "Nothing found" message displayed; true otherwise
  #
  def results?() ! find(locator(:no_results_message)) end

  ##
  #
  # The number of items returned by the search as reported by Craigslist. This
  # value will be the total over all result pages, not just this page.
  #
  # *Returns:*
  # * +Fixnum+ - Number of items returned by search
  #
  def count
    # There are two occurrences, but they are the same
    total = first locator(:total)
    return total.text.to_i if total
    results? ? raise(RuntimeError, "Couldn't determine result count", caller) : 0
  end

  ##
  #
  # The list of items returned on this page. It will be a maximum of 100
  # and not the entire result set.
  #
  # *Returns:*
  # * +Array[String]+ - Array of items returned by search
  #
  def items
    all(locator(:item)).map do |item|
      item.find(locator(:item_name)).text
    end
  end

  VALID_SEARCH_PARAMETERS = [
    :category,       # events, for sale, gigs...
    :city,           # albuquerque, el paso, santa fe...
    :has_image,      # true/false
    :max_price,      # Float (as string)
    :min_price,      # Float (as string)
    :posted_today,   # true/false
    :search_nearby,  # true/false
    :search_text,    # search string
    :subcategory,    # electronics, computers, farm+garden...
    :titles_only,    # true/false
  ]

  ##
  #
  # Search for particular items via Craigslist search
  #
  # *Parameters:*
  # * +search_by+ - keyword-based search parameters. See VALID_SEARCH_PARAMETERS for list of valid keys
  #
  # *Returns:*
  # * +Object+ - Page object of results page
  #
  def search_for(**search_by)
    search_by.keys.each do |key|
      raise "Illegal search modifier: #{key}" unless VALID_SEARCH_PARAMETERS.member?(key)
    end

    log.info "[ACTION] Search with #{search_by.to_json}"

    # Remove these 3 from search_by as they are used to next loop doesn't try to use them
    fill_in_if(:search_text, search_by.delete(:search_text))
    fill_in_if(:min_price,   search_by.delete(:min_price))
    fill_in_if(:max_price,   search_by.delete(:max_price))

    search_by.each do |locate_by, value|
      set_checkbox(locate_by, value)
    end

    click_search

    # Return WebPage object
    self.class.send(:given)
  end
end
