require 'spec_helper_system'

describe 'osg::condor_cron class:' do
  context "when default parameters" do
    it 'should run successfully' do
      pp =<<-EOS
  class { 'osg::condor_cron': service_ensure => 'stopped', service_autorestart => false }
      EOS
  
      puppet_apply(pp) do |r|
       r.exit_code.should_not == 1
       r.refresh
       r.exit_code.should be_zero
      end
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
