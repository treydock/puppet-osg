require 'spec_helper_system'

describe 'osg::bestman class:' do
  context "when default parameters" do
    it 'should run successfully' do
      pp =<<-EOS
        class { 'sudo': purge => false, config_file_replace => false }
        class { 'osg::lcmaps': gums_hostname => 'gums.foo' }
        class { 'osg::bestman': service_ensure => 'stopped', service_autorestart => false }
      EOS

      puppet_apply(pp) do |r|
       r.exit_code.should_not == 1
       r.refresh
       r.exit_code.should be_zero
      end
    end

    describe package('osg-se-bestman') do
      it { should be_installed }
    end

    describe service('bestman2') do
      it { should be_enabled }
      it { should_not be_running }
    end
  end
end
