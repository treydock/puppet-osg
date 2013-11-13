require 'spec_helper_system'
=begin
describe 'Real world usage of osg::gums class:' do

  context 'should run successfully' do
    pp = <<-EOS
      class { 'mysql::server': }
      class { 'osg': }
      class { 'osg::cacerts':
        crl_boot_service_enable => false,
      }
      class { 'osg::cacerts::updater':
        quiet   => false,
        logfile => '/var/log/osg-ca-certs-updater-cron.log',
      }
      class { 'osg::gums':
        db_password => 'secret',
      }
    EOS

    context puppet_apply(pp) do
      # Removed as deprecation warnings produced from numerous modules
      #its(:stderr) { should be_empty }
      its(:exit_code) { should_not == 1 }
      its(:refresh) { should be_nil }
      # Removed as deprecation warnings produced from numerous modules
      #its(:stderr) { should be_empty }
      its(:exit_code) { should be_zero }
    end
  end
end
=end
