require 'spec_helper'

describe 'osg::cacerts::updater' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({
          :concat_basedir => '/dne',
        })
      end

      it { should create_class('osg::cacerts::updater') }
      it { should contain_class('osg::params') }
      it { should contain_class('osg::cacerts') }
      it { should contain_class('cron') }

      it do 
        should contain_package('osg-ca-certs-updater').with({
          :ensure   => 'installed',
          :name     => 'osg-ca-certs-updater',
          :before   => 'File[/etc/cron.d/osg-ca-certs-updater]',
          :require  => 'Yumrepo[osg]',
        })
      end

      it do
        should contain_service('osg-ca-certs-updater-cron').with({
          :ensure       => 'running',
          :enable       => 'true',
          :name         => 'osg-ca-certs-updater-cron',
          :hasstatus    => 'true',
          :hasrestart   => 'true',
          :subscribe    => 'File[/etc/cron.d/osg-ca-certs-updater]',
        })
      end

      it do
        should contain_file('/etc/cron.d/osg-ca-certs-updater').with({
          :ensure   => 'present',
          :replace  => 'true',
          :owner    => 'root',
          :group    => 'root',
          :mode     => '0644',
          :require  => 'Package[cronie]',
        })
      end

      it do
        verify_contents(catalogue, '/etc/cron.d/osg-ca-certs-updater', [
          '0 */6 * * * root [ ! -f /var/lock/subsys/osg-ca-certs-updater-cron ] || /usr/sbin/osg-ca-certs-updater -a 23 -x 72 -r 30 -q',
        ])
      end

      it do 
        should contain_package('fetch-crl').with({
          :ensure   => 'installed',
          :name     => 'fetch-crl',
          :require  => 'Yumrepo[osg]',
        })
      end

      it do
        should contain_service('fetch-crl-boot').with({
          :ensure       => 'stopped',
          :enable       => 'false',
          :name         => 'fetch-crl-boot',
          :hasstatus    => 'true',
          :hasrestart   => 'true',
          :require      => 'Package[fetch-crl]',
        })
      end

      it do
        should contain_service('fetch-crl-cron').with({
          :ensure       => 'running',
          :enable       => 'true',
          :name         => 'fetch-crl-cron',
          :hasstatus    => 'true',
          :hasrestart   => 'true',
          :require      => 'Package[fetch-crl]',
        })
      end

      context 'with service_ensure => stopped' do
        let(:params){{ :service_ensure => 'stopped' }}
        it { should contain_service('osg-ca-certs-updater-cron').with_ensure('stopped') }
      end

      context "with ensure => 'absent'" do
        let(:params) {{ :ensure => 'absent' }}
        it { should contain_package('osg-ca-certs-updater').with_ensure('absent') }
        it { should contain_service('osg-ca-certs-updater-cron').with_ensure('stopped') }
        it { should contain_service('osg-ca-certs-updater-cron').with_enable('false') }
        it { should contain_package('fetch-crl').with_ensure('absent') }
        it { should contain_service('fetch-crl-boot').with_ensure('stopped') }
        it { should contain_service('fetch-crl-boot').with_enable('false') }
        it { should contain_service('fetch-crl-cron').with_ensure('stopped') }
        it { should contain_service('fetch-crl-cron').with_enable('false') }
      end

      context "with ensure => 'disabled'" do
        let(:params) {{ :ensure => 'disabled' }}
        it { should contain_package('osg-ca-certs-updater').with_ensure('installed') }
        it { should contain_service('osg-ca-certs-updater-cron').with_ensure('stopped') }
        it { should contain_service('osg-ca-certs-updater-cron').with_enable('false') }
        it { should contain_package('fetch-crl').with_ensure('installed') }
        it { should contain_service('fetch-crl-boot').with_ensure('stopped') }
        it { should contain_service('fetch-crl-boot').with_enable('false') }
        it { should contain_service('fetch-crl-cron').with_ensure('stopped') }
        it { should contain_service('fetch-crl-cron').with_enable('false') }
      end

      context 'with logfile => /var/log/osg-ca-certs-updater.log' do
        let(:params){{ :logfile => '/var/log/osg-ca-certs-updater.log' }}
        it do
          verify_contents(catalogue, '/etc/cron.d/osg-ca-certs-updater', [
            '0 */6 * * * root [ ! -f /var/lock/subsys/osg-ca-certs-updater-cron ] || /usr/sbin/osg-ca-certs-updater -a 23 -x 72 -r 30 -q -l /var/log/osg-ca-certs-updater.log',
          ])
        end
      end

      context 'with logfile => /var/log/osg-ca-certs-updater.log and quiet => false' do
        let(:params){{ :quiet => false, :logfile => '/var/log/osg-ca-certs-updater.log' }}
        it do
          verify_contents(catalogue, '/etc/cron.d/osg-ca-certs-updater', [
            '0 */6 * * * root [ ! -f /var/lock/subsys/osg-ca-certs-updater-cron ] || /usr/sbin/osg-ca-certs-updater -a 23 -x 72 -r 30 -l /var/log/osg-ca-certs-updater.log',
          ])
        end
      end

      [
        'include_cron',
        'config_replace',
      ].each do |bool_param|
        context "with #{bool_param} => 'foo'" do
          let(:params) {{ bool_param.to_sym => 'foo' }}
          it { expect { should create_class('osg::cacerts::updater') }.to raise_error(Puppet::Error, /is not a boolean/) }
        end
      end

    end
  end
end
