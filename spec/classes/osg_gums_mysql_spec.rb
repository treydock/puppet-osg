require 'spec_helper'

describe 'osg::gums::mysql' do

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
      :db_name          => 'GUMS_1_3',
      :db_username      => 'gums',
      :db_password      => Digest::SHA1.hexdigest('gums'),
      :db_hostname      => 'localhost',
      :db_port          => '3306',
    }
  end

  let :params do
    param_defaults.merge({
      
    })
  end

  it { should contain_class('osg::gums') }

  it do 
    should contain_file('/usr/lib/gums/sql/setupDatabase-puppet.mysql').with({
      'ensure'  => 'present',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
      'require' => 'Package[osg-gums]',
      'before'  => "Mysql::Db[#{params[:db_name]}]",
    }) \
      .with_content(/^USE #{params[:db_name]};$/)
  end

  it do
    should contain_mysql__db(params[:db_name]).with({
      'user'      => params[:db_username],
      'password'  => params[:db_password],
      'host'      => params[:db_hostname],
      'grant'     => ['all'],
      'sql'       => '/usr/lib/gums/sql/setupDatabase-puppet.mysql',
    })
  end
end
