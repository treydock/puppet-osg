require 'spec_helper_system'

describe 'osg::condor_cron class:' do
  context 'should run successfully' do
    pp =<<-EOS
class { 'osg::condor_cron': service_ensure => 'stopped', service_autorestart => false }
    EOS
  
    context puppet_apply(pp) do
       its(:stderr) { should be_empty }
       its(:exit_code) { should_not == 1 }
       its(:refresh) { should be_nil }
       its(:stderr) { should be_empty }
       its(:exit_code) { should be_zero }
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
