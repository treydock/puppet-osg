require 'spec_helper_acceptance'

describe 'osg::rsv class:' do
  context "when default parameters" do
    it 'should run successfully' do
      pp =<<-EOS
        class { 'osg::rsv': service_ensure => 'stopped', service_autorestart => false }
      EOS
  
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    describe package('rsv') do
      it { should be_installed }
    end

    describe service('rsv') do
      it { should be_enabled }
    end
  end
end
