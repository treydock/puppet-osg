require 'spec_helper'

describe 'osg::condor_cron' do
  include_context :defaults

  let(:facts) { default_facts }

  let(:params) {{ }}

  it { should create_class('osg::condor_cron') }
  it { should contain_class('osg::params') }
  it { should include_class('osg::repo') }
  it { should include_class('osg::cacerts::empty') }

  it do
    should contain_user('cndrcron').with({
      'ensure'      => 'present',
      'name'        => 'cndrcron',
      'uid'         => nil,
      'home'        => '/var/lib/condor-cron',
      'shell'       => '/sbin/nologin',
      'system'      => 'true',
      'comment'     => 'Condor-cron service',
      'managehome'  => 'false',
    })
  end

  it do
    should contain_group('cndrcron').with({
      'ensure'  => 'present',
      'name'    => 'cndrcron',
      'gid'     => nil,
      'system'  => 'true',
    })
  end

  it do
    should contain_package('condor-cron').with({
      'ensure'  => 'installed',
      'before'  => 'File[/etc/condor-cron/condor_config]',
      'require' => ['Yumrepo[osg]', 'Package[empty-ca-certs]'],
    })
  end

  it { should_not contain_file('/etc/condor-cron/config.d/condor_ids') }

  it do
    should contain_file('/etc/condor-cron/condor_config').with({
      'ensure'  => 'present',
      'replace' => 'false',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
      'notify'  => 'Service[condor-cron]',
    })
  end

  it do
    should contain_service('condor-cron').with({
      'ensure'      => nil,
      'enable'      => 'true',
      'hasstatus'   => 'true',
      'hasrestart'  => 'true',
      'require'     => 'File[/etc/condor-cron/condor_config]',
    })
  end

  it do
    should contain_file('/var/lib/condor-cron').with({
      'ensure'  => 'directory',
      'path'    => '/var/lib/condor-cron',
      'owner'   => 'cndrcron',
      'group'   => 'cndrcron',
      'mode'    => '0755',
      'require' => 'Package[condor-cron]',
    })
  end

  it do
    should contain_file('/var/lib/condor-cron/execute').with({
      'ensure'  => 'directory',
      'path'    => '/var/lib/condor-cron/execute',
      'owner'   => 'cndrcron',
      'group'   => 'cndrcron',
      'mode'    => '0755',
      'require' => 'File[/var/lib/condor-cron]',
    })
  end

  it do
    should contain_file('/var/lib/condor-cron/spool').with({
      'ensure'  => 'directory',
      'path'    => '/var/lib/condor-cron/spool',
      'owner'   => 'cndrcron',
      'group'   => 'cndrcron',
      'mode'    => '0755',
      'require' => 'File[/var/lib/condor-cron]',
    })
  end

  it do
    should contain_file('/var/run/condor-cron').with({
      'ensure'  => 'directory',
      'owner'   => 'cndrcron',
      'group'   => 'cndrcron',
      'mode'    => '0755',
      'require' => 'Package[condor-cron]',
    })
  end

  it do
    should contain_file('/var/lock/condor-cron').with({
      'ensure'  => 'directory',
      'owner'   => 'cndrcron',
      'group'   => 'cndrcron',
      'mode'    => '0755',
      'require' => 'Package[condor-cron]',
    })
  end

  it do
    should contain_file('/var/log/condor-cron').with({
      'ensure'  => 'directory',
      'owner'   => 'cndrcron',
      'group'   => 'cndrcron',
      'mode'    => '0755',
      'require' => 'Package[condor-cron]',
    })
  end

  context "with user_uid => 100" do
    let(:params) {{ :user_uid => 100 }}
    it { should contain_user('cndrcron').with_uid('100') }
  end

  context "with group_gid => 100" do
    let(:params) {{ :group_gid => 100 }}
    it { should contain_group('cndrcron').with_gid('100') }
  end

  context "with manage_user => false" do
    let(:params) {{ :manage_user => false }}
    it { should_not contain_user('cndrcron') }
  end

  context "with manage_group => false" do
    let(:params) {{ :manage_group => false }}
    it { should_not contain_group('cndrcron') }
  end

  context "with ca_certs_type => 'osg'" do
    let(:params) {{ :ca_certs_type => 'osg' }}
    it { should include_class('osg::cacerts') }
    it { should contain_package('condor-cron').with_require(['Yumrepo[osg]', 'Package[osg-ca-certs]']) }
  end

  context "with ca_certs_type => 'igtf'" do
    let(:params) {{ :ca_certs_type => 'igtf' }}
    it { should include_class('osg::cacerts::igtf') }
    it { should contain_package('condor-cron').with_require(['Yumrepo[osg]', 'Package[igtf-ca-certs]']) }
  end

  context 'with service_ensure => stopped' do
    let(:params){{ :service_ensure => 'stopped' }}

    it { should contain_service('condor-cron').with_ensure('stopped') }
  end

  context 'with service_autorestart => false' do
    let(:params) {{ :service_autorestart => false }}
    it { should contain_file('/etc/condor-cron/condor_config').with_notify(nil) }
  end

  # Test service ensure and enable 'magic' values
  [
    'undef',
    'UNSET',
  ].each do |v|
    context "with service_ensure => '#{v}'" do
      let(:params) {{ :service_ensure => v }}
      it { should contain_service('condor-cron').with_ensure(nil) }
    end

    context "with service_enable => '#{v}'" do
      let(:params) {{ :service_enable => v }}
      it { should contain_service('condor-cron').with_enable(nil) }
    end
  end

  # Test verify_boolean parameters
  [
    'manage_user',
    'manage_group',
    'config_replace',
  ].each do |bool_param|
    context "with #{bool_param} => 'foo'" do
      let(:params) {{ bool_param.to_sym => 'foo' }}
      it { expect { should create_class('osg::condor_cron') }.to raise_error(Puppet::Error, /is not a boolean/) }
    end
  end
end
