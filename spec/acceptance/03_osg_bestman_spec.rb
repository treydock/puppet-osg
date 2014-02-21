require 'spec_helper_acceptance'

describe 'osg::bestman class:' do
  context "when default parameters" do
    it 'should run successfully' do
      pp =<<-EOS
        class { 'sudo': purge => false, config_file_replace => false }
        class { 'osg::lcmaps': gums_hostname => 'gums.foo' }
        class { 'osg::bestman': service_ensure => 'stopped', service_autorestart => false }
      EOS

      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
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
