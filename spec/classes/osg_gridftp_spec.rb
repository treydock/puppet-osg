require 'spec_helper'

describe 'osg::gridftp' do
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
      it { is_expected.to create_class('osg::gridftp') }

      it { is_expected.to contain_class('osg').that_comes_before('Class[osg::cacerts]') }
      it { is_expected.to contain_class('osg::cacerts').that_comes_before('Class[osg::gridftp::install]') }
      it { is_expected.to contain_class('osg::gridftp::install').that_comes_before('Class[osg::lcmaps_voms]') }
      it { is_expected.to contain_class('osg::lcmaps_voms').that_comes_before('Class[osg::configure::site_info]') }
      it { is_expected.to contain_class('osg::configure::site_info').that_comes_before('Class[osg::gridftp::config]') }
      it { is_expected.to contain_class('osg::gridftp::config').that_notifies('Class[osg::gridftp::service]') }
      it { is_expected.to contain_class('osg::gridftp::service') }

      it do
        is_expected.to contain_firewall('100 allow GridFTP').with(action: 'accept',
                                                                  dport: '2811',
                                                                  proto: 'tcp')
      end

      it do
        is_expected.to contain_firewall('100 allow GLOBUS_TCP_PORT_RANGE').with(action: 'accept',
                                                                                dport: '40000-41999',
                                                                                proto: 'tcp')
      end

      it do
        is_expected.to contain_firewall('100 allow GLOBUS_TCP_SOURCE_RANGE').with(action: 'accept',
                                                                                  sport: '40000-41999',
                                                                                  proto: 'tcp')
      end

      context 'when manage_firewall => false' do
        let(:params) { { manage_firewall: false } }

        it { is_expected.not_to contain_firewall('100 allow GridFTP') }
        it { is_expected.not_to contain_firewall('100 allow GLOBUS_TCP_PORT_RANGE') }
        it { is_expected.not_to contain_firewall('100 allow GLOBUS_TCP_SOURCE_RANGE') }
      end

      context 'osg::gridftp::install' do
        it do
          is_expected.to contain_package('osg-gridftp').with(ensure: 'present')
        end
      end

      context 'osg::gridftp::config' do
        it do
          is_expected.to contain_file('/etc/sysconfig/globus-gridftp-server').with(ensure: 'file',
                                                                                   owner: 'root',
                                                                                   group: 'root',
                                                                                   mode: '0644')
        end

        it do
          verify_contents(catalogue, '/etc/sysconfig/globus-gridftp-server', [
                            'export GLOBUS_TCP_PORT_RANGE=40000,41999',
                            'export GLOBUS_TCP_SOURCE_RANGE=40000,41999',
                          ])
        end

        it do
          is_expected.to contain_file('/etc/grid-security/hostcert.pem').with(ensure: 'file',
                                                                              owner: 'root',
                                                                              group: 'root',
                                                                              mode: '0444',
                                                                              source: nil,
                                                                              show_diff: 'false')
        end

        it do
          is_expected.to contain_file('/etc/grid-security/hostkey.pem').with(ensure: 'file',
                                                                             owner: 'root',
                                                                             group: 'root',
                                                                             mode: '0400',
                                                                             source: nil,
                                                                             show_diff: 'false')
        end

        context 'when hostcert_source and hostkey_source defined' do
          let(:params) { { hostcert_source: 'file:///foo/hostcert.pem', hostkey_source: 'file:///foo/hostkey.pem' } }

          it { is_expected.to contain_file('/etc/grid-security/hostcert.pem').with_source('file:///foo/hostcert.pem') }
          it { is_expected.to contain_file('/etc/grid-security/hostkey.pem').with_source('file:///foo/hostkey.pem') }
        end
      end

      context 'osg::gridftp::service' do
        it do
          is_expected.to contain_service('globus-gridftp-server').with(ensure: 'running',
                                                                       enable: 'true',
                                                                       hasstatus: 'true',
                                                                       hasrestart: 'true')
        end
      end

      context 'when standalone => false' do
        let(:params) { { standalone: false } }

        it { is_expected.to contain_class('osg::gridftp::install').that_comes_before('Class[osg::lcmaps_voms]') }
        it { is_expected.to contain_class('osg::lcmaps_voms').that_comes_before('Class[osg::gridftp::config]') }
        it { is_expected.to contain_class('osg::gridftp::config').that_notifies('Class[osg::gridftp::service]') }
        it { is_expected.to contain_class('osg::gridftp::service') }
      end
    end
  end
end
