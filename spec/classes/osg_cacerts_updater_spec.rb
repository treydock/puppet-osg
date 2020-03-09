require 'spec_helper'

describe 'osg::cacerts::updater' do
  on_supported_os(supported_os: [
                    {
                      'operatingsystem' => 'CentOS',
                      'operatingsystemrelease' => ['7'],
                    },
                  ]).each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to create_class('osg::cacerts::updater') }
      it { is_expected.to contain_class('osg::cacerts') }
      # it { should contain_class('cron') }

      it do
        is_expected.to contain_package('osg-ca-certs-updater').with(ensure: 'installed',
                                                                    name: 'osg-ca-certs-updater',
                                                                    before: 'File[/etc/cron.d/osg-ca-certs-updater]',
                                                                    require: 'Yumrepo[osg]')
      end

      it do
        is_expected.to contain_service('osg-ca-certs-updater-cron').with(ensure: 'running',
                                                                         enable: 'true',
                                                                         name: 'osg-ca-certs-updater-cron',
                                                                         hasstatus: 'true',
                                                                         hasrestart: 'true',
                                                                         subscribe: 'File[/etc/cron.d/osg-ca-certs-updater]')
      end

      it do
        is_expected.to contain_file('/etc/cron.d/osg-ca-certs-updater').with(ensure: 'present',
                                                                             replace: 'true',
                                                                             owner: 'root',
                                                                             group: 'root',
                                                                             mode: '0644')
      end

      it do
        verify_contents(catalogue, '/etc/cron.d/osg-ca-certs-updater', [
                          '0 */6 * * * root [ ! -f /var/lock/subsys/osg-ca-certs-updater-cron ] || /usr/sbin/osg-ca-certs-updater -a 23 -x 72 -r 30 -q',
                        ])
      end

      context 'with service_ensure => stopped' do
        let(:params) { { service_ensure: 'stopped' } }

        it { is_expected.to contain_service('osg-ca-certs-updater-cron').with_ensure('stopped') }
      end

      context "with ensure => 'absent'" do
        let(:params) { { ensure: 'absent' } }

        it { is_expected.to contain_package('osg-ca-certs-updater').with_ensure('absent') }
        it { is_expected.to contain_service('osg-ca-certs-updater-cron').with_ensure('stopped') }
        it { is_expected.to contain_service('osg-ca-certs-updater-cron').with_enable('false') }
      end

      context "with ensure => 'disabled'" do
        let(:params) { { ensure: 'disabled' } }

        it { is_expected.to contain_package('osg-ca-certs-updater').with_ensure('installed') }
        it { is_expected.to contain_service('osg-ca-certs-updater-cron').with_ensure('stopped') }
        it { is_expected.to contain_service('osg-ca-certs-updater-cron').with_enable('false') }
      end

      context 'with logfile => /var/log/osg-ca-certs-updater.log' do
        let(:params) { { logfile: '/var/log/osg-ca-certs-updater.log' } }

        it do
          verify_contents(catalogue, '/etc/cron.d/osg-ca-certs-updater', [
                            '0 */6 * * * root [ ! -f /var/lock/subsys/osg-ca-certs-updater-cron ] || /usr/sbin/osg-ca-certs-updater -a 23 -x 72 -r 30 -q -l /var/log/osg-ca-certs-updater.log',
                          ])
        end
      end

      context 'with logfile => /var/log/osg-ca-certs-updater.log and quiet => false' do
        let(:params) { { quiet: false, logfile: '/var/log/osg-ca-certs-updater.log' } }

        it do
          verify_contents(catalogue, '/etc/cron.d/osg-ca-certs-updater', [
                            '0 */6 * * * root [ ! -f /var/lock/subsys/osg-ca-certs-updater-cron ] || /usr/sbin/osg-ca-certs-updater -a 23 -x 72 -r 30 -l /var/log/osg-ca-certs-updater.log',
                          ])
        end
      end
    end
  end
end
