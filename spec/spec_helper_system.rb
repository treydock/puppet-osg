require 'rspec-system/spec_helper'
require 'rspec-system-puppet/helpers'

include RSpecSystemPuppet::Helpers

# Project root for the this module's code
def proj_root
  File.expand_path(File.join(File.dirname(__FILE__), '..'))
end

def fixtures_root
  File.expand_path(File.join(proj_root, 'spec', 'fixtures'))
end

RSpec.configure do |c|
  # Enable colour in Jenkins
  c.tty = true

  c.include RSpecSystemPuppet::Helpers

  # This is where we 'setup' the nodes before running our tests
  c.before :suite do
    # Install puppet
    puppet_install
    puppet_master_install

    # Install module dependencies
    shell('puppet module install puppetlabs/stdlib --modulepath /etc/puppet/modules --force')
    shell('puppet module install puppetlabs/mysql --modulepath /etc/puppet/modules --force')
    shell('puppet module install puppetlabs/firewall --modulepath /etc/puppet/modules --force')
    shell('puppet module install stahnma/epel --modulepath /etc/puppet/modules --force')
    
    # Install osg module
    puppet_module_install(:source => proj_root, :module_name => 'osg')
  end
end