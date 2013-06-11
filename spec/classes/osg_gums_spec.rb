require 'spec_helper'

describe 'osg::gums' do

  let :facts do
    RSpec.configuration.default_facts.merge({

    })
  end

  let :pre_condition do
    [
      "class { 'mysql::server': }",
    ]
  end

  let :param_defaults do
    {
      :db_name          => 'GUMS_1_3',
      :db_username      => 'gums',
      :db_password      => Digest::SHA1.hexdigest('gums'),
      :db_hostname      => 'localhost',
      :db_port          => '3306',
      :manage_firewall  => true,
      :firewall_port    => '8443',
      :manage_tomcat    => true,
    }
  end

  let :params do
    param_defaults.merge({
      
    })
  end

  it { should contain_class('osg') }
  it { should include_class('osg::repo') }
  it { should include_class('osg::cacerts') }
  it { should include_class('firewall') }
  it { should include_class('osg::tomcat') }

  it do 
    should contain_package('osg-gums').with({
      'ensure'  => 'installed',
      'require' => 'Yumrepo[osg]',
    })
  end

  it do
    should contain_file('/root/gums-post-install.sh').with({
      'ensure'  => 'present',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0700',
    }) \
      .with_content(/^TOMCAT_CMD="\/var\/lib\/trustmanager-tomcat\/configure.sh"$/) \
      .with_content(/^GUMS_CMD="\/usr\/bin\/gums-setup-mysql-database --user #{params[:db_username]} --host #{params[:db_hostname]}:#{params[:db_port]} --password #{params[:db_password]} --noprompt"$/)
  end

  it do
    should contain_firewall('100 allow GUMS access').with({
      'port'    => params[:firewall_port],
      'proto'   => 'tcp',
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
end
