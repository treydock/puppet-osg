require 'beaker-rspec'

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
        dependency[:version] = m[1].tr("'|\"", "").strip
        dependencies << dependency
      else
        next
      end
    end

    dependencies
  end
end

include SystemHelper

dir = File.expand_path(File.dirname(__FILE__))
Dir["#{dir}/acceptance/support/*.rb"].sort.each {|f| require f}

hosts.each do |host|
  #install_puppet
  if host['platform'] =~ /el-(5|6)/
    relver = $1
    on host, "rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-#{relver}.noarch.rpm", { :acceptable_exit_codes => [0,1] }
    on host, 'yum install -y puppet', { :acceptable_exit_codes => [0,1] }
  end
end

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation

  c.include SystemHelper

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module
    puppet_module_install(:source => proj_root, :module_name => 'osg')

    hosts.each do |host|
      # Install module dependencies
      modulefile_dependencies.each do |mod|
        on host, puppet("module", "install", "#{mod[:fullname]}", "--version",  "'#{mod[:version]}'"), { :acceptable_exit_codes => [0,1] }
      end

      on host, 'yum -y install git'
      on host, '[ -d "/etc/puppet/modules/cron" ] || git clone git://github.com/treydock/puppet-cron.git /etc/puppet/modules/cron'

      scp_to host, File.join(proj_root, 'spec/fixtures/make-dummy-cert'), '/tmp/make-dummy-cert'
      on host, '/tmp/make-dummy-cert /tmp/host /tmp/bestman /tmp/rsv /tmp/http'
    end
  end
end
