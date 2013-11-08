require 'spec_helper'

describe 'osg::cacerts::updater' do

  let(:facts) { default_facts }

  it { should create_class('osg::cacerts::updater') }
  it { should contain_class('osg::params') }
  it { should include_class('osg::cacerts') }
  it { should include_class('cron') }

  it do 
    should contain_package('osg-ca-certs-updater').with({
      'ensure'  => 'installed',
      'name'    => 'osg-ca-certs-updater',
      'before'  => 'File[/etc/cron.d/osg-ca-certs-updater]',
      'require' => 'Yumrepo[osg]',
    })
  end

  it do
    should contain_service('osg-ca-certs-updater-cron').with({
      'ensure'      => 'running',
      'enable'      => 'true',
      'name'        => 'osg-ca-certs-updater-cron',
      'hasstatus'   => 'true',
      'hasrestart'  => 'true',
      'subscribe'   => 'File[/etc/cron.d/osg-ca-certs-updater]',
    })
  end

  it do
    should contain_file('/etc/cron.d/osg-ca-certs-updater').with({
      'ensure'  => 'present',
      'replace' => 'true',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
      'require' => 'Package[cronie]',
    })
  end

  it do
    verify_contents(subject, '/etc/cron.d/osg-ca-certs-updater', [
      '0 */6 * * * root [ ! -f /var/lock/subsys/osg-ca-certs-updater-cron ] || /usr/sbin/osg-ca-certs-updater -a 23 -x 72 -r 30 -q',
    ])
  end

  it do 
    should contain_package('fetch-crl').with({
      'ensure'  => 'installed',
      'name'    => 'fetch-crl',
      'require' => 'Yumrepo[osg]',
    })
  end

  it do
    should contain_service('fetch-crl-boot').with({
      'ensure'      => 'running',
      'enable'      => 'true',
      'name'        => 'fetch-crl-boot',
      'hasstatus'   => 'true',
      'hasrestart'  => 'true',
      'require'     => 'Package[fetch-crl]',
    })
  end

  it do
    should contain_service('fetch-crl-cron').with({
      'ensure'      => 'running',
      'enable'      => 'true',
      'name'        => 'fetch-crl-cron',
      'hasstatus'   => 'true',
      'hasrestart'  => 'true',
      'require'     => 'Package[fetch-crl]',
    })
  end

  context 'with service_ensure => stopped' do
    let(:params){{ :service_ensure => 'stopped' }}

    it { should contain_service('osg-ca-certs-updater-cron').with_ensure('stopped') }
  end

  context 'with service_ensure => "undef"' do
    let(:params) {{ :service_ensure => "undef" }}
    it { should contain_service('osg-ca-certs-updater-cron').with_ensure(nil) }
  end

  context 'with service_enable => "undef"' do
    let(:params) {{ :service_enable => "undef" }}
    it { should contain_service('osg-ca-certs-updater-cron').with_enable(nil) }
  end

  context 'with service_autorestart => false' do
    let(:params) {{ :service_autorestart => false }}
    it { should contain_service('osg-ca-certs-updater-cron').with_subscribe(nil) }
  end

  context 'with logfile => /var/log/osg-ca-certs-updater.log' do
    let(:params){{ :logfile => '/var/log/osg-ca-certs-updater.log' }}
    it do
      verify_contents(subject, '/etc/cron.d/osg-ca-certs-updater', [
        '0 */6 * * * root [ ! -f /var/lock/subsys/osg-ca-certs-updater-cron ] || /usr/sbin/osg-ca-certs-updater -a 23 -x 72 -r 30 -q -l /var/log/osg-ca-certs-updater.log',
      ])
    end
  end

  context 'with logfile => /var/log/osg-ca-certs-updater.log and quiet => false' do
    let(:params){{ :quiet => false, :logfile => '/var/log/osg-ca-certs-updater.log' }}
    it do
      verify_contents(subject, '/etc/cron.d/osg-ca-certs-updater', [
        '0 */6 * * * root [ ! -f /var/lock/subsys/osg-ca-certs-updater-cron ] || /usr/sbin/osg-ca-certs-updater -a 23 -x 72 -r 30 -l /var/log/osg-ca-certs-updater.log',
      ])
    end
  end

  [
    'service_autorestart',
    'include_cron',
    'replace_config',
  ].each do |bool_param|
    context "with #{bool_param} => 'foo'" do
      let(:params) {{ bool_param.to_sym => 'foo' }}
      it { expect { should create_class('osg::cacerts::updater') }.to raise_error(Puppet::Error, /is not a boolean/) }
    end
  end
end
