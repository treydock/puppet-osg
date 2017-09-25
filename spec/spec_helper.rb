require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'
require 'lib/module_spec_helper'

include RspecPuppetFacts

# Coveralls loading
begin
  require 'simplecov'
  require 'coveralls'
  SimpleCov.formatter = Coveralls::SimpleCov::Formatter
  SimpleCov.start do
    add_filter '/spec/'
  end
rescue Exception => e
  warn "Coveralls disabled"
end

at_exit { RSpec::Puppet::Coverage.report! }

RSpec.configure do |config|
  config.mock_with :rspec
end

add_custom_fact :sudoversion, '1.8.6p3'
add_custom_fact :root_home, '/root'
