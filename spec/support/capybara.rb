# frozen_string_literal: true
# TODO  Webdrivers.cache_time = 3
Capybara.default_max_wait_time = 8
Capybara.default_driver = :rack_test

# Setup chrome headless driver
# Capybara.server = :puma, { Silent: false }
ENV['WEB_HOST'] ||= `hostname -s`.strip

capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
  chromeOptions: {
    args: %w[disable-gpu no-sandbox whitelisted-ips window-size=1400,1400]
  }
)

Capybara.register_driver :chrome do |app|
  d = Capybara::Selenium::Driver.new(app,
                                     browser: :remote,
                                     desired_capabilities: capabilities,
                                     url: "http://chrome:4444/wd/hub")
  # Fix for capybara vs remote files. Selenium handles this for us
  d.browser.file_detector = lambda do |args|
    str = args.first.to_s
    str if File.exist?(str)
  end
  d
end
Capybara.server_host = '0.0.0.0'
Capybara.server_port = 3007
Capybara.always_include_port = true
Capybara.app_host = "http://#{ENV['WEB_HOST']}:#{Capybara.server_port}"
Capybara.javascript_driver = :chrome

# Setup rspec
RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, type: :system, js: true) do
    # rails system specs reset app_host each time so needs to be forced on each test
    Capybara.app_host = "http://#{ENV['WEB_HOST']}:#{Capybara.server_port}"
    driven_by :chrome
  end
end

module CapybaraExtension
  delegate :drag_by, to: :base
end

module CapybaraSeleniumExtension
  def drag_by(right_by, down_by)
    driver.browser.action.drag_and_drop_by(native, right_by, down_by).perform
  end
end

::Capybara::Selenium::Node.send :include, CapybaraSeleniumExtension
::Capybara::Node::Element.send :include, CapybaraExtension
