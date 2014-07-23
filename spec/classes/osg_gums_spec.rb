require 'spec_helper'

describe 'osg::gums' do
  include_context :defaults

  let(:facts) { default_facts }

  let :pre_condition do
    [
      "class { 'mysql::server': }",
    ]
  end

  it { should create_class('osg::gums') }
  it { should contain_class('osg::params') }

  it { should contain_anchor('osg::gums::start').that_comes_before('Class[osg]') }
  it { should contain_class('osg').that_comes_before('Class[osg::cacerts]') }
  it { should contain_class('osg::cacerts').that_comes_before('Class[osg::gums::install]') }
  it { should contain_class('osg::gums::install').that_comes_before('Class[osg::gums::config]') }
  it { should contain_class('osg::gums::config').that_notifies('Class[osg::gums::service]') }
  it { should contain_class('osg::gums::service').that_comes_before('Anchor[osg::gums::end]') }
  it { should contain_anchor('osg::gums::end') }

  it do
    should contain_firewall('100 allow GUMS access').with({
      :port     => '8443',
      :proto    => 'tcp',
      :iniface  => 'eth0',
      :action   => 'accept',
    })
  end

  context 'when manage_firewall => false' do
    let(:params) {{ :manage_firewall  => false }}
    it { should_not contain_firewall('100 allow GUMS access') }
  end

  context 'when firewall_interface => eth1' do
    let(:params) {{ :firewall_interface  => 'eth1' }}
    it { should contain_firewall('100 allow GUMS access').with_iniface('eth1') }
  end

  context 'osg::gums::install' do
    it do 
      should contain_package('osg-gums').with({
        :ensure   => 'installed',
      })
    end
  end

  context 'osg::gums::config' do
    it do
      should contain_file('/etc/grid-security/http').with({
        :ensure => 'directory',
        :owner  => 'root',
        :group  => 'root',
        :mode   => '0755',
      })
    end

    it do
      should contain_file('/etc/grid-security/http/httpcert.pem').with({
        :ensure   => 'file',
        :owner    => 'tomcat',
        :group    => 'tomcat',
        :mode     => '0444',
        :source   => nil,
        :require  => 'File[/etc/grid-security/http]',
      })
    end

    it do
      should contain_file('/etc/grid-security/http/httpkey.pem').with({
        :ensure   => 'file',
        :owner    => 'tomcat',
        :group    => 'tomcat',
        :mode     => '0400',
        :source   => nil,
        :require  => 'File[/etc/grid-security/http]',
      })
    end

    it do
      should contain_file('/etc/gums/gums.config').with({
        :ensure   => 'file',
        :content  => nil,
        :owner    => 'tomcat',
        :group    => 'tomcat',
        :mode     => '0600',
        :replace  => 'false',
      })
    end

    it do 
      should contain_file('/etc/tomcat6/server.xml').with({
        :ensure   => 'file',
        :owner    => 'tomcat',
        :group    => 'root',
        :mode     => '0664',
        :notify   => 'Service[tomcat6]',
      }) \
        .with_content(/^\s+<Connector\sport="8443"\sSSLEnabled="true"$/)
    end

    it do 
      should contain_file('/etc/tomcat6/log4j-trustmanager.properties').with({
        :ensure   => 'file',
        :source   => 'file:///var/lib/trustmanager-tomcat/log4j-trustmanager.properties',
        :owner    => 'root',
        :group    => 'root',
        :mode     => '0644',
        :notify   => 'Service[tomcat6]',
      })
    end

    [
      'bcprov.jar',
      'trustmanager.jar',
      'trustmanager-tomcat.jar',
      'commons-logging.jar',
    ].each do |jar|
      it do
        should contain_file("/usr/share/tomcat6/lib/#{jar}").with({
          :ensure   => 'link',
          :target   => "/usr/share/java/#{jar}",
        })
      end
    end

    it do 
      should contain_file('/usr/lib/gums/sql/setupDatabase-puppet.mysql').with({
        :ensure   => 'file',
        :owner    => 'root',
        :group    => 'root',
        :mode     => '0644',
        :before   => "Mysql::Db[GUMS_1_3]",
      }) \
        .with_content(/^USE GUMS_1_3;$/)
    end

    it do
      should contain_mysql__db('GUMS_1_3').with({
        :user       => 'gums',
        :password   => 'changeme',
        :host       => 'localhost',
        :grant      => ['ALL'],
        :sql        => '/usr/lib/gums/sql/setupDatabase-puppet.mysql',
      })
    end

    context 'when manage_tomcat => false' do
      let(:params) {{ :manage_tomcat => false }}

      it { should_not contain_file('/etc/tomcat6/server.xml') }
      it { should_not contain_file('/etc/tomcat6/log4j-trustmanager.properties') }
      [
        'bcprov.jar',
        'trustmanager.jar',
        'trustmanager-tomcat.jar',
        'commons-logging.jar',
      ].each do |jar|
        it { should_not contain_file("/usr/share/tomcat6/lib/#{jar}") }
      end
    end

    context 'when manage_mysql => false' do
      let(:params) {{ :manage_mysql => false }}
      it { should_not contain_file('/usr/lib/gums/sql/setupDatabase-puppet.mysql') }
      it { should_not contain_mysql__db('GUMS_1_3') }
    end
  end

  context 'osg::gums::service' do
    it do
      should contain_service('tomcat6').with({
        :ensure       => 'running',
        :enable       => 'true',
        :hasstatus    => 'true',
        :hasrestart   => 'true',
      })
    end

    context 'when manage_tomcat => false' do
      let(:params) {{ :manage_tomcat => false }}
      it { should_not contain_service('tomcat6') }
    end
  end
end
