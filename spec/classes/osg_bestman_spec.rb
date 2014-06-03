require 'spec_helper'

describe 'osg::bestman' do
  include_context :defaults

  let(:facts) { default_facts }

  let(:params) {{ }}

  let :pre_condition do
    [
      "class { 'osg::lcmaps': gums_hostname => 'gums.foo' }",
    ]
  end

  it { should create_class('osg::bestman') }
  it { should contain_class('osg::params') }

  it { should contain_anchor('osg::bestman::start').that_comes_before('Class[osg]') }
  it { should contain_class('osg').that_comes_before('Class[osg::cacerts]') }
  it { should contain_class('osg::cacerts').that_comes_before('Class[osg::bestman::install]') }
  it { should contain_class('osg::bestman::install').that_comes_before('Class[osg::gums::client]') }
  it { should contain_class('osg::gums::client').that_comes_before('Class[osg::bestman::config]') }
  it { should contain_class('osg::bestman::config').that_comes_before('Class[osg::bestman::service]') }
  it { should contain_class('osg::bestman::service').that_comes_before('Anchor[osg::bestman::end]') }
  it { should contain_anchor('osg::bestman::end') }

  it do
    should contain_firewall('100 allow SRMv2 access').with({
      :port    => '8443',
      :proto   => 'tcp',
      :action  => 'accept',
    })
  end

  context 'osg::bestman::install' do
    it do
      should contain_package('osg-se-bestman').with({
        :ensure  => 'installed',
      })
    end
  end

  context 'osg::bestman::config' do

    it { should contain_sudo__conf('bestman').with_priority('10') }

    it do
      content = catalogue.resource('file', '10_bestman').send(:parameters)[:content]
      content.split("\n").reject { |c| c =~ /(^#|^$)/ }.should == [
        'Defaults:bestman !requiretty',
        'Cmnd_Alias SRM_CMD = /bin/rm,/bin/mkdir,/bin/rmdir,/bin/mv,/bin/cp,/bin/ls',
        'Runas_Alias SRM_USR = ALL,!root',
        'bestman ALL=(SRM_USR) NOPASSWD: SRM_CMD'
      ]
    end

    it do
      should contain_file('/etc/grid-security/hostcert.pem').with({
        :ensure => 'file',
        :owner  => 'root',
        :group  => 'root',
        :mode   => '0444',
        :source => nil,
      })
    end

    it do
      should contain_file('/etc/grid-security/hostkey.pem').with({
        :ensure => 'file',
        :owner  => 'root',
        :group  => 'root',
        :mode   => '0400',
        :source => nil,
      })
    end

    it do
      should contain_file('/etc/grid-security/bestman').with({
        :ensure => 'directory',
        :owner  => 'root',
        :group  => 'root',
        :mode   => '0755',
      })
    end

    it do
      should contain_file('/etc/grid-security/bestman/bestmancert.pem').with({
        :ensure   => 'file',
        :owner    => 'bestman',
        :group    => 'bestman',
        :mode     => '0444',
        :source   => nil,
        :require  => 'File[/etc/grid-security/bestman]',
      })
    end

    it do
      should contain_file('/etc/grid-security/bestman/bestmankey.pem').with({
        :ensure   => 'file',
        :owner    => 'bestman',
        :group    => 'bestman',
        :mode     => '0400',
        :source   => nil,
        :require  => 'File[/etc/grid-security/bestman]',
      })
    end


    it do
      should contain_file('/etc/sysconfig/bestman2').with({
        :ensure  => 'file',
        :owner   => 'root',
        :group   => 'root',
        :mode    => '0644',
        :notify  => 'Service[bestman2]',
      })
    end

    it do
      content = catalogue.resource('file', '/etc/sysconfig/bestman2').send(:parameters)[:content]
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
        'GLOBUS_HOSTNAME=foo.example.tld',
        'BESTMAN_MAX_JAVA_HEAP=1024',
        'BESTMAN_EVENT_LOG_COUNT=10',
        'BESTMAN_EVENT_LOG_SIZE=20971520',
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
        :ensure  => 'file',
        :owner   => 'root',
        :group   => 'root',
        :mode    => '0644',
        :notify  => 'Service[bestman2]',
      })
    end

    it do
      content = catalogue.resource('file', '/etc/bestman2/conf/bestman2.rc').send(:parameters)[:content]
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
        'GUMSserviceURL=https://gums.example.tld:8443/gums/services/GUMSXACMLAuthorizationServicePort',
        'GUMSCurrHostDN=/DC=com/DC=DigiCert-Grid/O=Open Science Grid/OU=Services/CN=foo.example.tld',
        'disableSpaceMgt=true',
        'useBerkeleyDB=false',
        'noCacheLog=true',
        'Concurrency=40',
        'FactoryID=srm/v2/server',
        'noEventLog=false',
      ]
    end


    it do
      should contain_file('/var/log/bestman2').with({
        :ensure  => 'directory',
        :owner   => 'bestman',
        :group   => 'bestman',
        :mode    => '0755',
      })
    end

    context 'when bestmancert_source and bestmankey_source defined' do
      let(:params) {{ :bestmancert_source => 'file:///foo/hostcert.pem', :bestmankey_source => 'file:///foo/hostkey.pem' }}

      it { should contain_file('/etc/grid-security/hostcert.pem').without_source }
      it { should contain_file('/etc/grid-security/hostkey.pem').without_source }
      it { should contain_file('/etc/grid-security/bestman/bestmancert.pem').with_source('file:///foo/hostcert.pem') }
      it { should contain_file('/etc/grid-security/bestman/bestmankey.pem').with_source('file:///foo/hostkey.pem') }
    end

    context 'when hostcert_source and hostkey_source defined' do
      let(:params) {{ :hostcert_source => 'file:///foo/hostcert.pem', :hostkey_source => 'file:///foo/hostkey.pem' }}

      it { should contain_file('/etc/grid-security/hostcert.pem').with_source('file:///foo/hostcert.pem') }
      it { should contain_file('/etc/grid-security/hostkey.pem').with_source('file:///foo/hostkey.pem') }
      it { should contain_file('/etc/grid-security/bestman/bestmancert.pem').without_source }
      it { should contain_file('/etc/grid-security/bestman/bestmankey.pem').without_source }
    end
  end

  context 'osg::bestman::service' do
    it do
      should contain_service('bestman2').with({
        :ensure      => 'running',
        :enable      => 'true',
        :hasstatus   => 'true',
        :hasrestart  => 'true',
      })
    end
  end

  context "with localPathListAllowed => ['/tmp','/home']" do
    let(:params) {{ :localPathListAllowed => ['/tmp', '/home'] }}
    it { verify_contents(catalogue, '/etc/bestman2/conf/bestman2.rc', ['localPathListAllowed=/tmp;/home']) }
  end

  context "with localPathListToBlock => ['/etc','/root']" do
    let(:params) {{ :localPathListToBlock => ['/etc', '/root'] }}
    it { verify_contents(catalogue, '/etc/bestman2/conf/bestman2.rc', ['localPathListToBlock=/etc;/root']) }
  end

  context "with supportedProtocolList => ['gsiftp://gridftp1.example.com','gsiftp://gridftp2.example.com']" do
    let(:params) {{ :supportedProtocolList => ['gsiftp://gridftp1.example.com','gsiftp://gridftp2.example.com'] }}
    it { verify_contents(catalogue, '/etc/bestman2/conf/bestman2.rc', ['supportedProtocolList=gsiftp://gridftp1.example.com;gsiftp://gridftp2.example.com']) }
  end

  context "with host_dn => '/CN=foo'" do
    let(:params) {{ :host_dn => '/CN=foo' }}
    it { verify_contents(catalogue, '/etc/bestman2/conf/bestman2.rc', ['GUMSCurrHostDN=/CN=foo']) }
  end

  context "with globus_hostname => 'foo.example.com'" do
    let(:params) {{ :globus_hostname => 'foo.example.com' }}
    it { verify_contents(catalogue, '/etc/sysconfig/bestman2', ['GLOBUS_HOSTNAME=foo.example.com']) }
  end

  context 'with sudo_srm_commands => ["/foo/bar"]' do
    let(:params){{ :sudo_srm_commands => ['/foo/bar'] }}
    it do
      content = catalogue.resource('file', '10_bestman').send(:parameters)[:content]
      content.split("\n").reject { |c| c =~ /(^#|^$)/ }.should == [
        'Defaults:bestman !requiretty',
        'Cmnd_Alias SRM_CMD = /foo/bar',
        'Runas_Alias SRM_USR = ALL,!root',
        'bestman ALL=(SRM_USR) NOPASSWD: SRM_CMD'
      ]
    end
  end

  context 'with sudo_srm_commands => "/bin/rm, /bin/mkdir, /bin/rmdir, /bin/mv, /bin/cp, /bin/ls"' do
    let(:params){{ :sudo_srm_commands => '/bin/rm, /bin/mkdir, /bin/rmdir, /bin/mv, /bin/cp, /bin/ls' }}
    it do
      content = catalogue.resource('file', '10_bestman').send(:parameters)[:content]
      content.split("\n").reject { |c| c =~ /(^#|^$)/ }.should == [
        'Defaults:bestman !requiretty',
        'Cmnd_Alias SRM_CMD = /bin/rm, /bin/mkdir, /bin/rmdir, /bin/mv, /bin/cp, /bin/ls',
        'Runas_Alias SRM_USR = ALL,!root',
        'bestman ALL=(SRM_USR) NOPASSWD: SRM_CMD'
      ]
    end
  end

  context 'with sudo_srm_runas => "ALL, !root"' do
    let(:params){{ :sudo_srm_runas => 'ALL, !root' }}
    it do
      content = catalogue.resource('file', '10_bestman').send(:parameters)[:content]
      content.split("\n").reject { |c| c =~ /(^#|^$)/ }.should == [
        'Defaults:bestman !requiretty',
        'Cmnd_Alias SRM_CMD = /bin/rm,/bin/mkdir,/bin/rmdir,/bin/mv,/bin/cp,/bin/ls',
        'Runas_Alias SRM_USR = ALL, !root',
        'bestman ALL=(SRM_USR) NOPASSWD: SRM_CMD'
      ]
    end
  end

  context "with event_log_count => 20" do
    let(:params) {{ :event_log_count => 20 }}
    it { verify_contents(catalogue, '/etc/sysconfig/bestman2', ['BESTMAN_EVENT_LOG_COUNT=20']) }
  end

  context "with event_log_size => 50000000" do
    let(:params) {{ :event_log_size => 50000000 }}
    it { verify_contents(catalogue, '/etc/sysconfig/bestman2', ['BESTMAN_EVENT_LOG_SIZE=50000000']) }
  end

  context 'with manage_firewall => false' do
    let(:params) {{ :manage_firewall => false }}
    it { should_not contain_firewall('100 allow SRMv2 access') }
  end

  context 'with manage_sudo => false' do
    let(:params) {{ :manage_sudo => false }}
    it { should_not contain_sudo__conf('bestman') }
  end

  # Test validate_bool parameters
  [
    'manage_firewall',
    'manage_sudo',
  ].each do |param|
    context "with #{param} => 'foo'" do
      let(:params) {{ param.to_sym => 'foo' }}
      it { expect { should create_class('osg::bestman') }.to raise_error(Puppet::Error, /is not a boolean/) }
    end
  end

  # Test validate_array parameters
  [
    'localPathListToBlock',
    'localPathListAllowed',
    'supportedProtocolList',
  ].each do |param|
    context "with #{param} => 'foo'" do
      let(:params) {{ param.to_sym => 'foo' }}
      it { expect { should create_class('osg::bestman') }.to raise_error(Puppet::Error, /is not an Array/) }
    end
  end
end
