require 'spec_helper'

describe 'osg::ce' do
  include_context :defaults

  let(:facts) { default_facts }

  let(:params) {{ }}

  it { should create_class('osg::ce') }
  it { should contain_class('osg::params') }
  it { should contain_class('osg') }

  it do
    should contain_class('osg::gridftp').with({
      :cacerts_package_name        => 'osg-ca-certs',
      :cacerts_package_ensure      => 'installed',
      :hostcert_source             => 'UNSET',
      :hostkey_source              => 'UNSET',
    })
  end

  it { should contain_anchor('osg::ce::start').that_comes_before('Class[osg::gridftp]') }
  it { should contain_class('osg::gridftp').that_comes_before('Class[osg::ce::install]') }
  it { should contain_class('osg::ce::install').that_comes_before('Class[osg::ce::config]') }
  it { should contain_class('osg::ce::config').that_comes_before('Class[osg::ce::service]') }
  it { should contain_class('osg::ce::service').that_comes_before('Anchor[osg::ce::end]') }
  it { should contain_anchor('osg::ce::end') }

  context 'osg::ce::install' do
    it do
      should contain_package('empty-torque').with({
        :ensure => 'present',
        :before => 'Package[osg-ce]',
      })
    end

    it do
      should contain_package('osg-ce').with({
        :ensure => 'present',
        :name   => 'osg-ce-pbs',
      })
    end

    it do
      should contain_package('osg-configure-slurm').with({
        :ensure   => 'present',
        :require  => 'Package[osg-ce]',
      })
    end
  end

  context 'osg::ce::config' do
    it do
      should contain_file('/etc/grid-security/http').with({
        :ensure => 'directory',
        :owner  => 'tomcat',
        :group  => 'tomcat',
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
  end

  context 'osg::ce::service' do
    it do
      should contain_service('globus-gatekeeper').with({
        :ensure     => 'running',
        :enable     => 'true',
        :hasstatus  => 'true',
        :hasrestart => 'true',
        :before     => 'Service[tomcat6]', 
      })
    end

    it do
      should contain_service('tomcat6').with({
        :ensure     => 'running',
        :enable     => 'true',
        :hasstatus  => 'true',
        :hasrestart => 'true',
        :before     => 'Service[gratia-probes-cron]', 
      })
    end

    it do
      should contain_service('gratia-probes-cron').with({
        :ensure     => 'running',
        :enable     => 'true',
        :hasstatus  => 'true',
        :hasrestart => 'true',
        :before     => 'Service[osg-cleanup-cron]', 
      })
    end

    it do
      should contain_service('osg-cleanup-cron').with({
        :ensure     => 'running',
        :enable     => 'true',
        :hasstatus  => 'true',
        :hasrestart => 'true',
        :before     => nil, 
      })
    end
  end
end
