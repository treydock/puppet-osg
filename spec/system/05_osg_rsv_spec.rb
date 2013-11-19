require 'spec_helper_system'

describe 'osg::rsv class:' do
  context 'should run successfully' do
    pp =<<-EOS
class { 'osg::rsv': service_ensure => 'stopped', service_autorestart => false }
    EOS
  
    context puppet_apply(pp) do
       its(:stderr) { should be_empty }
       its(:exit_code) { should_not == 1 }
       its(:refresh) { should be_nil }
       its(:stderr) { should be_empty }
       its(:exit_code) { should be_zero }
    end
  end

  describe package('rsv') do
    it { should be_installed }
  end

  describe service('rsv') do
    it { should be_enabled }
  end
end
