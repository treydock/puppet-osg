require 'puppetlabs_spec_helper/module_spec_helper'

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
    }
  end
end
