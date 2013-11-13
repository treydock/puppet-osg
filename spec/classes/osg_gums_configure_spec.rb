require 'spec_helper'

describe 'osg::gums::configure' do
  include_context :defaults

  let :facts do
    default_facts.merge({

    })
  end

  let :pre_condition do
    [
      "class { 'mysql::server': }",
    ]
  end

  let :param_defaults do
    {
      :port               => '8443',
    }
  end

  let :params do
    param_defaults.merge({
      
    })
  end

  it { should contain_class('osg::gums') }

  it do 
    should contain_file('/etc/tomcat6/server.xml').with({
      'ensure'  => 'present',
      'owner'   => 'tomcat',
      'group'   => 'root',
      'mode'    => '0664',
      'require' => 'Package[osg-gums]',
    }) \
      .with_content(/^\s+<Connector\sport="#{params[:port]}"\sSSLEnabled="true"$/)
  end

  it do 
    should contain_file('/etc/tomcat6/log4j-trustmanager.properties').with({
      'ensure'  => 'present',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
      'require' => 'Package[osg-gums]',
    })
  end

  # TODO: Content for log4j-trustmanager.properties

  [
    'bcprov.jar',
    'trustmanager.jar',
    'trustmanager-tomcat.jar',
    'commons-logging.jar',
  ].each do |jar|
    it do
      should contain_file("/usr/share/tomcat6/lib/#{jar}").with({
        'ensure'  => 'link',
        'target'  => "/usr/share/java/#{jar}",
        'require' => 'Package[osg-gums]',
      })
    end
  end
end
