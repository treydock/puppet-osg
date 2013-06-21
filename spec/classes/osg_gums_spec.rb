require 'spec_helper'

describe 'osg::gums' do

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
      :db_name            => 'GUMS_1_3',
      :db_username        => 'gums',
      :db_password        => Digest::SHA1.hexdigest('gums'),
      :db_hostname        => 'localhost',
      :db_port            => '3306',
      :port               => '8443',
      :manage_firewall    => true,
      :firewall_interface => 'eth0',
      :manage_tomcat      => true,
      :manage_mysql       => true,
    }
  end

  let :params do
    param_defaults.merge({
      
    })
  end

  it { should contain_class('osg::params') }
  it { should include_class('osg::repo') }
  it { should include_class('osg::cacerts') }
  it { should include_class('osg::gums::configure') }
  it { should include_class('firewall') }
  it { should include_class('osg::tomcat') }
  it { should include_class('osg::gums::mysql') }

  it do 
    should contain_package('osg-gums').with({
      'ensure'  => 'installed',
      'require' => 'Yumrepo[osg]',
    })
  end

  it do
    should contain_file('/etc/gums/gums.config').with({
      'ensure'  => 'present',
      'content' => nil,
      'owner'   => 'tomcat',
      'group'   => 'tomcat',
      'mode'    => '0600',
      'replace' => 'false',
      'require' => 'Package[osg-gums]',
    })
  end

  it do
    should contain_firewall('100 allow GUMS access').with({
      'port'    => params[:port],
      'proto'   => 'tcp',
      'iniface' => params[:firewall_interface],
      'action'  => 'accept',
    })
  end

  context 'with manage_tomcat => false' do
    let :params do
      param_defaults.merge({
        :manage_tomcat  => false,
      })
    end

    it { should_not include_class('osg::tomcat') }
  end

  context 'with manage_firewall => false' do
    let :params do
      param_defaults.merge({
        :manage_firewall  => false,
      })
    end

    it { should_not contain_class('firewall') }
    it { should_not contain_firewall('100 allow GUMS access') }
  end

  context 'with manage_mysql => false' do
    let :params do
      param_defaults.merge({
        :manage_mysql  => false,
      })
    end

    it { should_not contain_class('osg::gums::mysql') }
  end

  context 'with firewall_interface => eth1' do
    let :params do
      param_defaults.merge({
        :firewall_interface => 'eth1',
      })
    end

    it { should contain_firewall('100 allow GUMS access').with_iniface('eth1') }
  end
end
