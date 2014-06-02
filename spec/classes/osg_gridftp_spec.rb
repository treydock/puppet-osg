require 'spec_helper'

describe 'osg::gridftp' do
  include_context :defaults

  let(:facts) { default_facts }

  let(:params) {{ }}

  it { should create_class('osg::gridftp') }
  it { should contain_class('osg::params') }

  it { should contain_anchor('osg::gridftp::start').that_comes_before('Class[osg]') }
  it { should contain_class('osg').that_comes_before('Class[osg::cacerts]') }
  it { should contain_class('osg::cacerts').with({
      :package_name   => 'empty-ca-certs',
      :package_ensure => 'installed',
    }).that_comes_before('Class[osg::gridftp::install]') }
  it { should contain_class('osg::gridftp::install').that_comes_before('Class[osg::gums::client]') }
  it { should contain_class('osg::gums::client').that_comes_before('Class[osg::gridftp::config]') }
  it { should contain_class('osg::gridftp::config').that_notifies('Class[osg::gridftp::service]') }
  it { should contain_class('osg::gridftp::service').that_comes_before('Anchor[osg::gridftp::end]') }
  it { should contain_anchor('osg::gridftp::end') }

  it do
    should contain_firewall('100 allow GridFTP').with({
      :action => 'accept',
      :dport  => '2811',
      :proto  => 'tcp',
    })
  end

  it do
    should contain_firewall('100 allow GLOBUS_TCP_PORT_RANGE').with({
      :action => 'accept',
      :dport  => '40000-41999',
      :proto  => 'tcp',
    })
  end

  it do
    should contain_firewall('100 allow GLOBUS_TCP_SOURCE_RANGE').with({
      :action => 'accept',
      :sport  => '40000-41999',
      :proto  => 'tcp',
    })
  end

  context 'osg::gridftp::install' do
    it do
      should contain_package('osg-gridftp').with({
        :ensure => 'present',
      })
    end
  end

  context 'osg::gridftp::config' do
    it do
      should contain_file('/etc/sysconfig/globus-gridftp-server').with({
        :ensure => 'file',
        :owner  => 'root',
        :group  => 'root',
        :mode   => '0644',
      })
    end

    it do
      verify_contents(catalogue, '/etc/sysconfig/globus-gridftp-server', [
        'export GLOBUS_TCP_PORT_RANGE=40000,41999',
        'export GLOBUS_TCP_SOURCE_RANGE=40000,41999',
      ])
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
      should contain_file('/etc/grid-security/grid-mapfile').with({
        :ensure   => 'file',
        :owner    => 'root',
        :group    => 'root',
        :mode     => '0644',
        :source   => nil,
        :content  => nil,
      })
    end

    context 'when hostcert_source and hostkey_source defined' do
      let(:params) {{ :hostcert_source => 'file:///foo/hostcert.pem', :hostkey_source => 'file:///foo/hostkey.pem' }}

      it { should contain_file('/etc/grid-security/hostcert.pem').with_source('file:///foo/hostcert.pem') }
      it { should contain_file('/etc/grid-security/hostkey.pem').with_source('file:///foo/hostkey.pem') }
    end
  end

  context 'osg::gridftp::service' do
    it do
      should contain_service('globus-gridftp-server').with({
        :ensure     => 'running',
        :enable     => 'true',
        :hasstatus  => 'true',
        :hasrestart => 'true',
      })
    end
  end
end
