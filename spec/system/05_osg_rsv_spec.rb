require 'spec_helper_system'

describe 'osg::rsv class:' do
  context "when default parameters" do
    it 'should run successfully' do
      pp =<<-EOS
  class { 'osg::rsv': service_ensure => 'stopped', service_autorestart => false }
      EOS
  
      puppet_apply(pp) do |r|
       r.exit_code.should_not == 1
       r.refresh
       r.exit_code.should be_zero
      end
    end

    describe package('rsv') do
      it { should be_installed }
    end

    describe service('rsv') do
      it { should be_enabled }
    end
  end
end
