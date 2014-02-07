require 'rspec-system/spec_helper'
require 'rspec-system-puppet/helpers'
require 'rspec-system-serverspec/helpers'

include RSpecSystemPuppet::Helpers
include Serverspec::Helper::RSpecSystem
include Serverspec::Helper::DetectOS

module SystemHelper
  def proj_root
    File.expand_path(File.join(File.dirname(__FILE__), '..'))
  end

  def modulefile_dependencies
    dependencies = []

    modulefile = File.join(proj_root, "Modulefile")
    
    return false unless File.exists?(modulefile)

    File.open(modulefile).each do |line|
      if line =~ /^dependency\s+(.*)/
        dependency = {}
        m = $1.split(',')
        fullname = m[0].tr("'|\"", "")
        dependency[:fullname] = fullname
        dependency[:name] = fullname.split("/").last
        dependency[:version] = m[1].tr("'|\"", "").strip unless m[1].nil?
        dependencies << dependency
      else
        next
      end
    end

    dependencies
  end
end

include SystemHelper

RSpec.configure do |c|
  # Project root for the this module's code
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Enable colour in Jenkins
  c.tty = true

  c.include RSpecSystemPuppet::Helpers
  c.include SystemHelper

  # This is where we 'setup' the nodes before running our tests
  c.before :suite do
    # Install puppet
    puppet_install
    puppet_master_install

    # Install module dependencies
    modulefile_dependencies.each do |mod|
      shell("[ -d /etc/puppet/modules/#{mod[:name]} ] || puppet module install #{mod[:fullname]} --modulepath /etc/puppet/modules --version '#{mod[:version]}'")
    end

    shell('yum -y install git')
    shell('git clone git://github.com/treydock/puppet-cron.git /etc/puppet/modules/cron')
    
    # Install osg module
    puppet_module_install(:source => proj_root, :module_name => 'osg')
  end
end