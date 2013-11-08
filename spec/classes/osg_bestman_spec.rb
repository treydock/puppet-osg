require 'spec_helper'

describe 'osg::bestman' do

  let(:facts) { default_facts }

  let :param_defaults do
    {
      :user_name              => 'bestman',
      :ca_certs_type          => 'empty',
      :with_gridmap_auth      => false,
      :grid_map_file_name        => '/etc/bestman2/conf/grid-mapfile.empty',
      :with_gums_auth         => true,
      :gums_hostname          => 'yourgums.yourdomain',
      :gums_port              => '8443',
      :bestman_gumscertpath   => '/etc/grid-security/bestman/bestmancert.pem',
      :bestman_gumskeypath    => '/etc/grid-security/bestman/bestmankey.pem',
      :manage_firewall        => true,
      :port                   => '8443',
      :firewall_interface     => 'eth0',
      :localPathListToBlock   => [],
      :localPathListAllowed   => [],
      :cert_file_name           => '/etc/grid-security/bestman/bestmancert.pem',
      :key_file_name            => '/etc/grid-security/bestman/bestmankey.pem',
      :supportedProtocolList  => [],
      :service_ensure         => 'running',
      :service_enable         => true,
      :service_autorestart    => true,
    }
  end

  let(:params) { param_defaults }

  it { should create_class('osg::bestman') }
  it { should contain_class('osg::params') }
  it { should include_class('osg::repo') }
  it { should include_class('osg::cacerts::empty') }
  it { should include_class('firewall') }

  it do
    should contain_firewall('100 allow bestman2 access').with({
      'port'    => params[:port],
      'proto'   => 'tcp',
      'iniface' => params[:firewall_interface],
      'action'  => 'accept',
    })
  end

  it do 
    should contain_package('osg-se-bestman').with({
      'ensure'  => 'installed',
      'require' => 'Yumrepo[osg]',
    })
  end

  it do
    should contain_file('/etc/grid-security/gsi-authz.conf').with({
      'ensure'  => 'present',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
      'notify'  => 'Service[bestman2]',
      'before'  => 'Service[bestman2]',
      'require' => 'Package[osg-se-bestman]',
    })
  end

  it do
    should contain_file('/etc/lcmaps.db').with({
      'ensure'  => 'present',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
      'notify'  => 'Service[bestman2]',
      'before'  => 'Service[bestman2]',
      'require' => 'Package[osg-se-bestman]',
    })
  end

  it do
    should contain_file('/etc/sysconfig/bestman2').with({
      'ensure'  => 'present',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
      'notify'  => 'Service[bestman2]',
      'before'  => 'Service[bestman2]',
      'require' => 'Package[osg-se-bestman]',
    })
  end

  it do
    should contain_file('/etc/bestman2/conf/bestman2.rc').with({
      'ensure'  => 'present',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
      'notify'  => 'Service[bestman2]',
      'before'  => 'Service[bestman2]',
      'require' => 'Package[osg-se-bestman]',
    })
  end

  it do
    should contain_service('bestman2').with({
      'ensure'      => 'running',
      'enable'      => 'true',
      'hasstatus'   => 'true',
      'hasrestart'  => 'true',
    })
  end
=begin
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
=end
end
