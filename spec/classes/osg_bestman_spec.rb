require 'spec_helper'

describe 'osg::bestman' do

  let(:facts) { default_facts }

  let(:params) {{ }}

  let :pre_condition do
    [
      "class { 'osg::lcmaps': gums_hostname => 'gums.foo' }",
    ]
  end

  it { should create_class('osg::bestman') }
  it { should contain_class('osg::params') }
  it { should include_class('osg::repo') }
  it { should include_class('osg::cacerts::empty') }
  it { should include_class('osg::lcmaps') }
  it { should include_class('firewall') }

  it do
    should contain_firewall('100 allow bestman2 access').with({
      'port'    => '8443',
      'proto'   => 'tcp',
      'iniface' => 'eth0',
      'action'  => 'accept',
    })
  end

  it do 
    should contain_package('osg-se-bestman').with({
      'ensure'  => 'installed',
      'require' => 'Yumrepo[osg]',
      'before'  => [ 'File[/etc/sysconfig/bestman2]', 'File[/etc/bestman2/conf/bestman2.rc]' ]
    })
  end

  it do
    should contain_file('/etc/sysconfig/bestman2').with({
      'ensure'  => 'present',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
    })
  end

  it do
    content = subject.resource('file', '/etc/sysconfig/bestman2').send(:parameters)[:content]
    content.split("\n").reject { |c| c =~ /(^#|^$)/ }.should == [
      'SRM_HOME=/etc/bestman2',
      'BESTMAN_SYSCONF=/etc/sysconfig/bestman2',
      'BESTMAN_SYSCONF_LIB=/etc/sysconfig/bestman2lib',
      'BESTMAN2_CONF=/etc/bestman2/conf/bestman2.rc',
      'JAVA_HOME=/etc/alternatives/java_sdk',
      'BESTMAN_LOG=/var/log/bestman2/bestman2.log',
      'BESTMAN_PID=/var/run/bestman2.pid',
      'BESTMAN_LOCK=/var/lock/bestman2',
      'SRM_OWNER=bestman',
      'BESTMAN_LIB=/usr/share/java/bestman2',
      'X509_CERT_DIR=/etc/grid-security/certificates',
      'BESTMAN_MAX_JAVA_HEAP=1024',
      'BESTMAN_GUMSCERTPATH=/etc/grid-security/bestman/bestmancert.pem',
      'BESTMAN_GUMSKEYPATH=/etc/grid-security/bestman/bestmankey.pem',
      'BESTMAN_GUMS_ENABLED=yes',
      'JETTY_DEBUG_ENABLED=no',
      'BESTMAN_GATEWAYMODE_ENABLED=yes',
      'BESTMAN_FULLMODE_ENABLED=no',
      'JAVA_CLIENT_MAX_HEAP=512',
      'JAVA_CLIENT_MIN_HEAP=32',
    ]
  end

  it do
    should contain_file('/etc/bestman2/conf/bestman2.rc').with({
      'ensure'  => 'present',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
    })
  end

  it do
    content = subject.resource('file', '/etc/bestman2/conf/bestman2.rc').send(:parameters)[:content]
    content.split("\n").reject { |c| c =~ /(^#|^$)/ }.should == [
      'EventLogLocation=/var/log/bestman2',
      'eventLogLevel=INFO',
      'securePort=8443',
      'CertFileName=/etc/grid-security/bestman/bestmancert.pem',
      'KeyFileName=/etc/grid-security/bestman/bestmankey.pem',
      'pathForToken=true',
      'fsConcurrency=40',
      'checkSizeWithFS=true',
      'checkSizeWithGsiftp=false',
      'accessFileSysViaSudo=true',
      'noSudoOnLs=true',
      'accessFileSysViaGsiftp=false',
      'MaxMappedIDCached=1000',
      'LifetimeSecondsMappedIDCached=1800',
      'GUMSProtocol=XACML',
      'GUMSserviceURL=https://gums.foo:8443/gums/services/GUMSXACMLAuthorizationServicePort',
      'disableSpaceMgt=true',
      'useBerkeleyDB=false',
      'noCacheLog=true',
      'Concurrency=40',
      'FactoryID=srm/v2/server',
      'noEventLog=false',
    ]
  end

  it do
    should contain_service('bestman2').with({
      'ensure'      => 'running',
      'enable'      => 'true',
      'hasstatus'   => 'true',
      'hasrestart'  => 'true',
      'subscribe'   => [ 'File[/etc/sysconfig/bestman2]', 'File[/etc/bestman2/conf/bestman2.rc]' ]
    })
  end

  context 'with service_ensure => stopped' do
    let(:params){{ :service_ensure => 'stopped' }}

    it { should contain_service('bestman2').with_ensure('stopped') }
  end

  context 'with service_ensure => "undef"' do
    let(:params) {{ :service_ensure => "undef" }}
    it { should contain_service('bestman2').with_ensure(nil) }
  end

  context 'with service_enable => "undef"' do
    let(:params) {{ :service_enable => "undef" }}
    it { should contain_service('bestman2').with_enable(nil) }
  end

  context 'with service_autorestart => false' do
    let(:params) {{ :service_autorestart => false }}
    it { should contain_service('bestman2').with_subscribe(nil) }
  end

  context 'with manage_firewall => false' do
    let(:params) {{ :manage_firewall => false }}
    it { should_not include_class('firewall') }
    it { should_not contain_firewall('100 allow bestman2 access') }
  end

  [
    'with_gridmap_auth',
    'with_gums_auth',
    'manage_firewall',
  ].each do |bool_param|
    context "with #{bool_param} => 'foo'" do
      let(:params) {{ bool_param.to_sym => 'foo' }}
      it { expect { should create_class('osg::cacerts::updater') }.to raise_error(Puppet::Error, /is not a boolean/) }
    end
  end
end
