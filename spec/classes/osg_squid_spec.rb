require 'spec_helper'

describe 'osg::squid' do
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

      let(:params) {{ }}

      it { should compile.with_all_deps }
      it { should create_class('osg::squid') }
      it { should contain_class('osg::params') }
      it { should contain_class('osg') }

      it do
        should contain_firewall('100 allow squid access').only_with({
          :name   => '100 allow squid access',
          :ensure => 'present',
          :port   => '3128',
          :proto  => 'tcp',
          :action => 'accept',
        })
      end

      it do
        should contain_firewall('101 allow squid monitoring from 128.142.0.0/16').only_with({
          :name     => '101 allow squid monitoring from 128.142.0.0/16',
          :ensure   => 'present',
          :port     => '3401',
          :proto    => 'udp',
          :source   => '128.142.0.0/16',
          :action   => 'accept',
        })
      end

      it do
        should contain_firewall('101 allow squid monitoring from 188.184.128.0/17').only_with({
          :name     => '101 allow squid monitoring from 188.184.128.0/17',
          :ensure   => 'present',
          :port     => '3401',
          :proto    => 'udp',
          :source   => '188.184.128.0/17',
          :action   => 'accept',
        })
      end

      it do
        should contain_firewall('101 allow squid monitoring from 188.185.128.0/17').only_with({
          :name     => '101 allow squid monitoring from 188.185.128.0/17',
          :ensure   => 'present',
          :port     => '3401',
          :proto    => 'udp',
          :source   => '188.185.128.0/17',
          :action   => 'accept',
        })
      end

      it do
        should contain_package('frontier-squid').with({
          :ensure  => 'present',
          :require => 'Yumrepo[osg]',
          :before  => 'File[/etc/squid/customize.sh]',
        })
      end

      it do
        should contain_file('/etc/squid/customize.sh').with({
          :ensure  => 'file',
          :owner   => 'squid',
          :group   => 'squid',
          :mode    => '0755',
        })
      end

      it do
        verify_exact_contents(catalogue, '/etc/squid/customize.sh', [
          'awk --file `dirname $0`/customhelps.awk --source \'{',
          'setoption("acl NET_LOCAL src", "10.0.0.0/8 172.16.0.0/12 192.168.0.0/16")',
          'setoption("acl localnet src", "10.0.0.0/8 172.16.0.0/12 192.168.0.0/16")',
          'setoption("cache_mem", "128 MB")',
          'setoptionparameter("cache_dir", 3, "10000")',
          'uncomment("acl MAJOR_CVMFS")',
          'insertline("^# http_access deny !RESTRICT_DEST", "http_access allow MAJOR_CVMFS")',
          'insertline("^# max_filedescriptors 0", "max_filedescriptors 0")',
          'print',
          '}\'',
        ])
      end

      it do
        should contain_service('frontier-squid').with({
          :ensure      => 'running',
          :enable      => 'true',
          :hasstatus   => 'true',
          :hasrestart  => 'true',
          :subscribe   => 'File[/etc/squid/customize.sh]',
        })
      end

      context "when manage_firewall => false" do
        let(:params) {{ :manage_firewall => false }}
        it { should_not contain_firewall('100 allow squid access') }
        it { should_not contain_firewall('101 allow squid monitoring from 128.142.0.0/16') }
        it { should_not contain_firewall('101 allow squid monitoring from 188.184.128.0/17') }
        it { should_not contain_firewall('101 allow squid monitoring from 188.185.128.0/17') }
      end

      context "when public_interface => 'eth1'" do
        let(:params) {{ :public_interface => 'eth1' }}
        it { should contain_firewall('100 allow squid access').without_iniface }
        it { should contain_firewall('101 allow squid monitoring from 128.142.0.0/16').with_iniface('eth1') }
        it { should contain_firewall('101 allow squid monitoring from 188.184.128.0/17').with_iniface('eth1') }
        it { should contain_firewall('101 allow squid monitoring from 188.185.128.0/17').with_iniface('eth1') }
      end

      context "when net_local => '192.168.200.0/24'" do
        let(:params) {{ :net_local => '192.168.200.0/24' }}
        it { verify_contents(catalogue, '/etc/squid/customize.sh', [
          'setoption("acl NET_LOCAL src", "192.168.200.0/24")',
          'setoption("acl localnet src", "192.168.200.0/24")'])
        }
      end

      # Test validate_bool parameters
      [
        'manage_firewall',
      ].each do |param|
        context "with #{param} => 'foo'" do
          let(:params) {{ param => 'foo' }}
          it { expect { should create_class('osg::squid') }.to raise_error(Puppet::Error, /is not a boolean/) }
        end
      end

    end
  end

end
