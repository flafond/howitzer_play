require 'rspec'
require 'capybara/rspec'
require_relative '../boot'

Dir[File.join(File.dirname(__FILE__), 'support', '**', '*.rb')].each{ |f| require f }

RSpec.configure do |config|
  log.settings_as_formatted_text

  DataStorage.store('sauce', :start_time, Time.now.utc)
  DataStorage.store('sauce', :status, true)

  config.include Capybara::Settings
  config.include Capybara::RSpecMatchers
  config.include DataGenerator

  config.disable_monkey_patching = true
  config.color = true

  config.before(:all) do
    if sauce_driver?
      suite_name = "#{(ENV['RAKE_TASK'] || 'CUSTOM').sub('rspec:', '').upcase} #{settings.sl_browser_name.upcase}"
      Capybara.drivers[:sauce][].options[:desired_capabilities][:name] = suite_name
    end
  end

  config.before(:each) do
    log.print_scenario_name(RSpec.current_example.description.empty? ? RSpec.current_example.metadata[:full_description] : RSpec.current_example.description)
    @session_start = duration(Time.now.utc - DataStorage.extract('sauce', :start_time))
  end

  config.after(:each) do
    DataStorage.clear_all_ns
    if sauce_driver?
      session_end = duration(Time.now.utc - DataStorage.extract('sauce', :start_time))
      log.info "SAUCE VIDEO #{@session_start} - #{session_end} URL: #{sauce_resource_path('video.flv')}"
    elsif ie_browser?
      log.info 'IE reset session'
      page.execute_script("void(document.execCommand('ClearAuthenticationCache', false));")
    end
  end

  config.after(:suite) do
    if sauce_driver?
      report_failures_count = config.reporter.instance_variable_get(:@failure_count)
      DataStorage.store('sauce', :status, report_failures_count.zero?)
    end
  end

  at_exit do
    if sauce_driver?
      log.info "SAUCE SERVER LOG URL: #{CapybaraSettings.sauce_resource_path('selenium-server.log')}"
      CapybaraSettings.update_sauce_job_status(passed: DataStorage.extract('sauce', :status))
    end
  end
end

##
#
# Check or clear a checkbox
#
# *Parameters:*
# * +locate_by+ - A field_locator id of the checkbox to check/clear
# * +value+ - set if truthy, clear otherwise
#
# *Returns:*
# * +Object+ - Object identified by locate_by
#
def set_checkbox(locate_by, value)
  value ? check(locator(locate_by)) : uncheck(locator(locate_by))
end

##
#
# Fill in a field only if the value is truthy; do nothing otherwise
#
# *Parameters:*
# * +locate_by+ - A field_locator id of the field to populate
# * +value+ - The value to populate the field with, IF it isn't false/nil
#
# *Returns:*
# * +Object+ - Object identified by locate_by
#
def fill_in_if(locate_by, value)
  fill_in field_locator(locate_by), with: value.to_s if value
end