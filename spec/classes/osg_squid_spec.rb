require 'spec_helper'

describe 'osg::squid' do
  on_supported_os(supported_os: [
                    {
                      'operatingsystem' => 'CentOS',
                      'operatingsystemrelease' => ['7'],
                    },
                  ]).each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      let(:params) { {} }

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to create_class('osg::squid') }
      it { is_expected.to contain_class('osg') }

      it do
        is_expected.to contain_firewall('100 allow squid access').only_with(name: '100 allow squid access',
                                                                            ensure: 'present',
                                                                            dport: '3128',
                                                                            proto: 'tcp',
                                                                            action: 'accept')
      end

      it do
        is_expected.to contain_firewall('101 allow squid monitoring from 128.142.0.0/16').only_with(name: '101 allow squid monitoring from 128.142.0.0/16',
                                                                                                    ensure: 'present',
                                                                                                    dport: '3401',
                                                                                                    proto: 'udp',
                                                                                                    source: '128.142.0.0/16',
                                                                                                    action: 'accept')
      end

      it do
        is_expected.to contain_firewall('101 allow squid monitoring from 188.184.128.0/17').only_with(name: '101 allow squid monitoring from 188.184.128.0/17',
                                                                                                      ensure: 'present',
                                                                                                      dport: '3401',
                                                                                                      proto: 'udp',
                                                                                                      source: '188.184.128.0/17',
                                                                                                      action: 'accept')
      end

      it do
        is_expected.to contain_firewall('101 allow squid monitoring from 188.185.128.0/17').only_with(name: '101 allow squid monitoring from 188.185.128.0/17',
                                                                                                      ensure: 'present',
                                                                                                      dport: '3401',
                                                                                                      proto: 'udp',
                                                                                                      source: '188.185.128.0/17',
                                                                                                      action: 'accept')
      end

      it do
        is_expected.to contain_package('frontier-squid').with(ensure: 'present',
                                                              require: 'Yumrepo[osg]',
                                                              before: 'File[/etc/squid/customize.sh]')
      end

      it do
        is_expected.to contain_file('/etc/squid/customize.sh').with(ensure: 'file',
                                                                    owner: 'squid',
                                                                    group: 'squid',
                                                                    mode: '0755')
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
                                'insertline("# INSERT YOUR OWN RULE", "acl URN proto URN")',
                                'insertline("# INSERT YOUR OWN RULE", "http_access deny URN")',
                                'print',
                                '}\'',
                              ])
      end

      it do
        is_expected.to contain_service('frontier-squid').with(ensure: 'running',
                                                              enable: 'true',
                                                              hasstatus: 'true',
                                                              hasrestart: 'true',
                                                              subscribe: 'File[/etc/squid/customize.sh]')
      end

      context 'when manage_firewall => false' do
        let(:params) { { manage_firewall: false } }

        it { is_expected.not_to contain_firewall('100 allow squid access') }
        it { is_expected.not_to contain_firewall('101 allow squid monitoring from 128.142.0.0/16') }
        it { is_expected.not_to contain_firewall('101 allow squid monitoring from 188.184.128.0/17') }
        it { is_expected.not_to contain_firewall('101 allow squid monitoring from 188.185.128.0/17') }
      end

      context "when public_interface => 'eth1'" do
        let(:params) { { public_interface: 'eth1' } }

        it { is_expected.to contain_firewall('100 allow squid access').without_iniface }
        it { is_expected.to contain_firewall('101 allow squid monitoring from 128.142.0.0/16').with_iniface('eth1') }
        it { is_expected.to contain_firewall('101 allow squid monitoring from 188.184.128.0/17').with_iniface('eth1') }
        it { is_expected.to contain_firewall('101 allow squid monitoring from 188.185.128.0/17').with_iniface('eth1') }
      end

      context "when net_local => '192.168.200.0/24'" do
        let(:params) { { net_local: ['192.168.200.0/24'] } }

        it {
          verify_contents(catalogue, '/etc/squid/customize.sh', [
                            'setoption("acl NET_LOCAL src", "192.168.200.0/24")',
                            'setoption("acl localnet src", "192.168.200.0/24")',
                          ])
        }
      end
    end
  end
end
