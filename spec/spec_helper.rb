require 'puppetlabs_spec_helper/module_spec_helper'

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

shared_context :defaults do
  let(:node) { 'foo.example.tld' }
  let(:default_facts) do
    {
      :kernel                 => 'Linux',
      :osfamily               => 'RedHat',
      :operatingsystem        => 'CentOS',
      :operatingsystemrelease => '6.4',
      :architecture           => 'x86_64',
      :os_maj_version         => '6',
      :concat_basedir         => '/tmp',
    }
  end
end

at_exit { RSpec::Puppet::Coverage.report! }
