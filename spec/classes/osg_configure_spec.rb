require 'spec_helper'

describe 'osg::configure' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({
          :concat_basedir => '/dne',
          :puppetversion => Puppet.version,
        })
      end

      it do
        should contain_exec('osg-configure').with({
          :path         => ['/usr/bin','/bin','/usr/sbin','/sbin'],
          :command      => '/usr/sbin/osg-configure -c',
          :onlyif       => ['test -f /usr/sbin/osg-configure', '/usr/sbin/osg-configure -v'],
          :refreshonly  => 'true',
        })
      end

    end
  end
end
