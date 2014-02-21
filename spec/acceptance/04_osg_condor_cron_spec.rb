require 'spec_helper_acceptance'

describe 'osg::condor_cron class:' do
  context "when default parameters" do
    it 'should run successfully' do
      pp =<<-EOS
        class { 'osg::condor_cron': service_ensure => 'stopped', service_autorestart => false }
      EOS
  
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    describe package('condor-cron') do
      it { should be_installed }
    end

    describe service('condor-cron') do
      it { should be_enabled }
      it { should_not be_running }
    end
  end
end
