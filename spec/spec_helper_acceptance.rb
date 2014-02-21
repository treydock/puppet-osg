require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'

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

hosts.each do |host|
  # Install Puppet
  install_puppet
end

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  c.include SystemHelper

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    puppet_module_install(:source => proj_root, :module_name => 'osg')

    hosts.each do |host|
      # Install module dependencies
      modulefile_dependencies.each do |mod|
        on host, puppet("module", "install", "#{mod[:fullname]}", "--version",  "'#{mod[:version]}'"), { :acceptable_exit_codes => [0,1] }
      end

      on host, shell('yum -y install git')
      on host, shell('git clone git://github.com/treydock/puppet-cron.git /etc/puppet/modules/cron')
    end
  end
end