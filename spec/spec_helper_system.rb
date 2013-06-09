require 'rspec-system/spec_helper'
require 'rspec-system-puppet/helpers'

module LocalHelpers
  # Project root for the this module's code
  def proj_root
    File.expand_path(File.join(File.dirname(__FILE__), '..'))
  end

  def fixtures_root
    File.expand_path(File.join(proj_root, 'spec', 'fixtures'))
  end
end

RSpec.configure do |c|
  # Enable colour in Jenkins
  c.tty = true

  # This is where we 'setup' the nodes before running our tests
  c.system_setup_block = proc do
    # TODO: find a better way of importing this into this namespace
    include RSpecSystemPuppet::Helpers
    include ::LocalHelpers

    # Install puppet
    puppet_install
    puppet_master_install

    # Install module dependencies
    shell('puppet module install puppetlabs-stdlib --modulepath /etc/puppet/modules')
    
    # Install osg module
    puppet_module_install(:source => proj_root, :module_name => 'osg')
  end
end