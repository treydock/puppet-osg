require 'spec_helper'

describe 'osg::cacerts::updater' do

  let :facts do
    default_facts.merge({

    })
  end

  it { should contain_class('osg::params') }
  it { should include_class('osg::repo') }
  it { should include_class('osg::cacerts') }

  it do 
    should contain_package('osg-ca-certs-updater').with({
      'ensure'  => 'installed',
      'name'    => 'osg-ca-certs-updater',
      'before'  => 'File[/etc/cron.d/osg-ca-certs-updater]',
      'require' => 'Package[osg-ca-certs]',
    })
  end

  it do
    should contain_service('osg-ca-certs-updater-cron').with({
      'ensure'      => 'running',
      'enable'      => 'true',
      'hasstatus'   => 'true',
      'hasrestart'  => 'true',
      'require'     => 'Package[osg-ca-certs-updater]',
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
    }) \
    .with_content(/^0 \*\/6 \* \* \* root/) \
    .with_content(/\[ ! -f \/var\/lock\/subsys\/osg-ca-certs-updater-cron \] ||/) \
    .with_content(/\/usr\/sbin\/osg-ca-certs-updater -a 23\s+-x 72\s+-r 30\s+-q\s+$/)
  end

  context 'with service_ensure => stopped' do
    let(:params){{ :service_ensure => 'stopped' }}

    it { should contain_service('osg-ca-certs-updater-cron').with_ensure('stopped') }
  end

  context 'with logfile => /var/log/osg-ca-certs-updater.log' do
    let(:params){{ :logfile => '/var/log/osg-ca-certs-updater.log' }}

    it do
      should contain_file('/etc/cron.d/osg-ca-certs-updater') \
        .with_content(/\/usr\/sbin\/osg-ca-certs-updater -a 23\s+-x 72\s+-r 30\s+-q\s+-l #{params[:logfile]}\s+$/)
    end
  end

  context 'with logfile => /var/log/osg-ca-certs-updater.log and quiet => false' do
    let(:params){{ :quiet => false, :logfile => '/var/log/osg-ca-certs-updater.log' }}

    it do
      should contain_file('/etc/cron.d/osg-ca-certs-updater') \
        .with_content(/\/usr\/sbin\/osg-ca-certs-updater -a 23\s+-x 72\s+-r 30\s+-l #{params[:logfile]}\s+$/)
    end
  end
end
