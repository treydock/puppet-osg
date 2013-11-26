require 'spec_helper'

describe 'osg::rsv' do
  include_context :defaults

  let(:facts) { default_facts }

  let(:params) {{ }}

  it { should create_class('osg::rsv') }
  it { should contain_class('osg::params') }
  it { should include_class('osg::condor_cron') }
  it { should include_class('osg::repo') }
  it { should include_class('osg::cacerts') }

  it do
    should contain_firewall('100 allow RSV http access').with({
      'port'    => '80',
      'proto'   => 'tcp',
      'action'  => 'accept',
    })
  end

  it do
    should contain_user('rsv').with({
      'ensure'      => 'present',
      'name'        => 'rsv',
      'uid'         => nil,
      'home'        => '/var/rsv',
      'shell'       => '/bin/sh',
      'system'      => 'true',
      'comment'     => 'RSV monitoring',
      'managehome'  => 'false',
    })
  end

  it do
    should contain_group('rsv').with({
      'ensure'  => 'present',
      'name'    => 'rsv',
      'gid'     => nil,
      'system'  => 'true',
    })
  end

  it do
    should contain_package('rsv').with({
      'ensure'  => 'installed',
      'before'  => ['File[/etc/rsv/rsv.conf]', 'File[/etc/rsv/consumers.conf]', 'File[/etc/osg/config.d/30-rsv.ini]'],
      'require' => ['Yumrepo[osg]', 'Package[osg-ca-certs]'],
    })
  end

  it do
    should contain_file('/etc/osg/config.d/30-rsv.ini').with({
      'ensure'  => 'present',
      'replace' => 'true',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
      'notify'  => 'Exec[osg-configure-rsv]',
    })
  end

  it do
    content = subject.resource('file', '/etc/osg/config.d/30-rsv.ini').send(:parameters)[:content]
    content.split("\n").reject { |c| c =~ /(^;|^$)/ }.should == [
      '[RSV]',
      'enabled = True',
      'enable_gratia = True',
      'service_cert  = /etc/grid-security/rsv/rsvcert.pem',
      'service_key  = /etc/grid-security/rsv/rsvkey.pem',
      'service_proxy = /tmp/rsvproxy',
      'ce_hosts = UNAVAILABLE',
      'gridftp_hosts = UNAVAILABLE',
      'gridftp_dir = DEFAULT',
      'gratia_probes = DEFAULT',
      'gums_hosts = UNAVAILABLE',
      'srm_hosts = UNAVAILABLE',
      'srm_dir = DEFAULT',
      'srm_webservice_path = DEFAULT',
      'enable_local_probes = True',
      'enable_nagios = False',
      'nagios_send_nsca = False',
      'condor_location = UNAVAILABLE',
    ]
  end

  it do
    should contain_file('/etc/rsv/rsv.conf').with({
      'ensure'  => 'present',
      'replace' => 'false',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
      'notify'  => 'Service[rsv]',
    })
  end

  it do
    should contain_file('/etc/rsv/consumers.conf').with({
      'ensure'  => 'present',
      'replace' => 'false',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
      'notify'  => 'Service[rsv]',
    })
  end

  it do
    should contain_service('rsv').with({
      'ensure'      => nil,
      'enable'      => 'true',
      'hasstatus'   => 'false',
      'hasrestart'  => 'true',
      'status'      => 'test -f /var/lock/subsys/rsv',
      'require'     => ['File[/etc/rsv/rsv.conf]', 'File[/etc/rsv/consumers.conf]', 'Service[condor-cron]'],
    })
  end

  it do
    should contain_file('/etc/grid-security/rsv/rsvcert.pem').with({
      'owner'   => 'rsv',
      'group'   => 'rsv',
      'mode'    => '0444',
      'require' => 'Package[rsv]',
    })
  end

  it do
    should contain_file('/etc/grid-security/rsv/rsvkey.pem').with({
      'owner'   => 'rsv',
      'group'   => 'rsv',
      'mode'    => '0400',
      'require' => 'Package[rsv]',
    })
  end

  it do
    should contain_file('/var/spool/rsv').with({
      'ensure'  => 'directory',
      'path'    => '/var/spool/rsv',
      'owner'   => 'rsv',
      'group'   => 'rsv',
      'mode'    => '0755',
      'require' => 'Package[rsv]',
    })
  end

  it do
    should contain_file('/var/tmp/rsv').with({
      'ensure'  => 'directory',
      'owner'   => 'rsv',
      'group'   => 'rsv',
      'mode'    => '0755',
      'require' => 'Package[rsv]',
    })
  end

  it do
    should contain_file('/var/log/rsv').with({
      'ensure'  => 'directory',
      'path'    => '/var/log/rsv',
      'owner'   => 'rsv',
      'group'   => 'rsv',
      'mode'    => '0755',
      'require' => 'Package[rsv]',
    })
  end

  it do
    should contain_file('/var/log/rsv/consumers').with({
      'ensure'  => 'directory',
      'path'    => '/var/log/rsv/consumers',
      'owner'   => 'rsv',
      'group'   => 'rsv',
      'mode'    => '0755',
      'require' => 'File[/var/log/rsv]',
    })
  end

  it do
    should contain_file('/var/log/rsv/metrics').with({
      'ensure'  => 'directory',
      'path'    => '/var/log/rsv/metrics',
      'owner'   => 'rsv',
      'group'   => 'rsv',
      'mode'    => '0755',
      'require' => 'File[/var/log/rsv]',
    })
  end

  context "with user_uid => 100" do
    let(:params) {{ :user_uid => 100 }}
    it { should contain_user('rsv').with_uid('100') }
  end

  context "with group_gid => 100" do
    let(:params) {{ :group_gid => 100 }}
    it { should contain_group('rsv').with_gid('100') }
  end

  context "with manage_user => false" do
    let(:params) {{ :manage_user => false }}
    it { should_not contain_user('rsv') }
  end

  context "with manage_group => false" do
    let(:params) {{ :manage_group => false }}
    it { should_not contain_group('rsv') }
  end

  context 'with service_ensure => running' do
    let(:params){{ :service_ensure => 'running' }}
    it { should contain_service('rsv').with_ensure('running') }
  end

  context 'with service_ensure => stopped' do
    let(:params){{ :service_ensure => 'stopped' }}

    it { should contain_service('rsv').with_ensure('stopped') }
  end

  context 'with manage_firewall => false' do
    let(:params) {{ :manage_firewall => false }}
    it { should_not contain_firewall('100 allow RSV http access') }
  end

  context 'with service_autorestart => false' do
    let(:params) {{ :service_autorestart => false }}
    it { should contain_file('/etc/rsv/rsv.conf').with_notify(nil) }
    it { should contain_file('/etc/rsv/consumers.conf').with_notify(nil) }
  end

  context 'with with_osg_configure => false' do
    let(:params) {{ :with_osg_configure => false }}
    it { should contain_file('/etc/osg/config.d/30-rsv.ini').with_notify(nil) }
  end

  # Test service ensure and enable 'magic' values
  [
    'undef',
    'UNSET',
  ].each do |v|
    context "with service_ensure => '#{v}'" do
      let(:params) {{ :service_ensure => v }}
      it { should contain_service('rsv').with_ensure(nil) }
    end

    context "with service_enable => '#{v}'" do
      let(:params) {{ :service_enable => v }}
      it { should contain_service('rsv').with_enable(nil) }
    end
  end

  # Test verify_boolean parameters
  [
    'manage_user',
    'manage_group',
    'with_httpd',
    'manage_firewall',
    'with_osg_configure',
    'config_replace',
    'configd_replace',
    'enable_gratia',
    'enable_local_probes',
  ].each do |bool_param|
    context "with #{bool_param} => 'foo'" do
      let(:params) {{ bool_param.to_sym => 'foo' }}
      it { expect { should create_class('osg::rsv') }.to raise_error(Puppet::Error, /is not a boolean/) }
    end
  end
end
