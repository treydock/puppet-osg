require 'spec_helper'

describe 'osg::configure' do
  on_supported_os({
    :supported_os => [
      {
        "operatingsystem" => "CentOS",
        "operatingsystemrelease" => ["6", "7"],
      }
    ]
  }).each do |os, facts|
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
          :onlyif       => ['test -f /usr/sbin/osg-configure'],
          :refreshonly  => 'true',
        })
      end

    end
  end
end
