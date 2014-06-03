require 'spec_helper'

describe 'osg::rsv' do
  include_context :defaults

  let(:facts) { default_facts }

  let(:params) {{ }}

  it { should create_class('osg::rsv') }
  it { should contain_class('osg::params') }

  it { should contain_anchor('osg::rsv::start').that_comes_before('Class[osg]') }
  it { should contain_class('osg').that_comes_before('Class[osg::cacerts]') }
  it { should contain_class('osg::cacerts').that_comes_before('Class[osg::rsv::users]') }
  it { should contain_class('osg::rsv::users').that_comes_before('Class[osg::rsv::install]') }
  it { should contain_class('osg::rsv::install').that_comes_before('Class[osg::rsv::config]') }
  it { should contain_class('osg::rsv::config').that_notifies('Class[osg::rsv::service]') }
  it { should contain_class('osg::rsv::service').that_comes_before('Anchor[osg::rsv::end]') }
  it { should contain_anchor('osg::rsv::end') }

  it do
    should contain_firewall('100 allow RSV http access').with({
      :ensure => 'present',
      :dport  => '80',
      :proto  => 'tcp',
      :action => 'accept',
    })
  end

  it { should contain_class('apache') }

  it do
    should contain_file('/etc/httpd/conf.d/rsv.conf').with({
      :ensure  => 'file',
      :owner   => 'root',
      :group   => 'root',
      :mode    => '0644',
      :require => 'Package[httpd]',
      :notify  => 'Service[httpd]',
    })
  end

  it do
    verify_contents(catalogue, '/etc/httpd/conf.d/rsv.conf', [
      '<Directory "/usr/share/rsv/www">',
      '    Options None',
      '    AllowOverride None',
      '    Order Allow,Deny',
      '    Allow from all',
      '</Directory>',
      'Alias /rsv /usr/share/rsv/www',
    ])
  end

  context 'osg::rsv::install' do
    it do
      should contain_package('rsv').with({
        :ensure  => 'installed',
      })
    end
  end

  context 'osg::rsv::users' do
    it do
      should contain_user('rsv').with({
        :ensure      => 'present',
        :name        => 'rsv',
        :uid         => nil,
        :home        => '/var/rsv',
        :shell       => '/bin/sh',
        :system      => 'true',
        :comment     => 'RSV monitoring',
        :managehome  => 'false',
      })
    end

    it do
      should contain_group('rsv').with({
        :ensure  => 'present',
        :name    => 'rsv',
        :gid     => nil,
        :system  => 'true',
      })
    end

    it do
      should contain_user('cndrcron').with({
        :ensure      => 'present',
        :name        => 'cndrcron',
        :uid         => '93',
        :home        => '/var/lib/condor-cron',
        :shell       => '/sbin/nologin',
        :system      => 'true',
        :comment     => 'Condor-cron service',
        :managehome  => 'false',
      })
    end

    it do
      should contain_group('cndrcron').with({
        :ensure  => 'present',
        :name    => 'cndrcron',
        :gid     => '93',
        :system  => 'true',
      })
    end
  end

  context 'osg::rsv::config' do

    [
      {:name => 'RSV/ce_hosts', :value => 'UNAVAILABLE'},
      {:name => 'RSV/gridftp_hosts', :value => 'UNAVAILABLE'},
      {:name => 'RSV/gridftp_dir', :value => 'DEFAULT'},
      {:name => 'RSV/gratia_probes', :value => 'DEFAULT'},
      {:name => 'RSV/srm_hosts', :value => 'UNAVAILABLE'},
      {:name => 'RSV/srm_dir', :value => 'DEFAULT'},
      {:name => 'RSV/srm_webservice_path', :value => 'DEFAULT'},
    ].each do |h|
      it do
        should contain_osg_config(h[:name]).with({
          :value  => h[:value],
          :path   => '30-rsv.ini',
        })
      end
    end

    it do
      should contain_file('/etc/grid-security/rsv').with({
        :ensure => 'directory',
        :owner  => 'root',
        :group  => 'root',
        :mode   => '0755',
      })
    end

    it do
      should contain_file('/etc/grid-security/rsv/rsvcert.pem').with({
        :ensure   => 'file',
        :owner    => 'rsv',
        :group    => 'rsv',
        :mode     => '0444',
        :source   => nil,
        :require  => 'File[/etc/grid-security/rsv]',
      })
    end

    it do
      should contain_file('/etc/grid-security/rsv/rsvkey.pem').with({
        :ensure   => 'file',
        :owner    => 'rsv',
        :group    => 'rsv',
        :mode     => '0400',
        :source   => nil,
        :require  => 'File[/etc/grid-security/rsv]',
      })
    end

    it do
      should contain_file('/var/spool/rsv').with({
        :ensure => 'directory',
        :owner  => 'rsv',
        :group  => 'rsv',
        :mode   => '0755',
      })
    end

    it do
      should contain_file('/var/log/rsv').with({
        :ensure => 'directory',
        :owner  => 'rsv',
        :group  => 'rsv',
        :mode   => '0755',
      })
    end

    it do
      should contain_file('/var/log/rsv/consumers').with({
        :ensure   => 'directory',
        :owner    => 'rsv',
        :group    => 'rsv',
        :mode     => '0755',
        :require  => 'File[/var/log/rsv]',
      })
    end

    it do
      should contain_file('/var/log/rsv/metrics').with({
        :ensure   => 'directory',
        :owner    => 'rsv',
        :group    => 'rsv',
        :mode     => '0755',
        :require  => 'File[/var/log/rsv]',
      })
    end

    it do
      should contain_file('/etc/condor-cron/config.d/condor_ids').with({
        :ensure => 'file',
        :owner  => 'root',
        :group  => 'root',
        :mode   => '0644',
      })
    end

    it do
      verify_contents(catalogue, '/etc/condor-cron/config.d/condor_ids', [
        'CONDOR_IDS = 93.93',
      ])
    end

    it do
      should contain_file('/var/lib/condor-cron').with({
        :ensure => 'directory',
        :owner  => 'cndrcron',
        :group  => 'cndrcron',
        :mode   => '0755',
      })
    end

    it do
      should contain_file('/var/lib/condor-cron/execute').with({
        :ensure   => 'directory',
        :owner    => 'cndrcron',
        :group    => 'cndrcron',
        :mode     => '0755',
        :require  => 'File[/var/lib/condor-cron]',
      })
    end

    it do
      should contain_file('/var/lib/condor-cron/spool').with({
        :ensure   => 'directory',
        :owner    => 'cndrcron',
        :group    => 'cndrcron',
        :mode     => '0755',
        :require  => 'File[/var/lib/condor-cron]',
      })
    end

    it do
      should contain_file('/var/run/condor-cron').with({
        :ensure => 'directory',
        :owner  => 'cndrcron',
        :group  => 'cndrcron',
        :mode   => '0755',
      })
    end

    it do
      should contain_file('/var/lock/condor-cron').with({
        :ensure => 'directory',
        :owner  => 'cndrcron',
        :group  => 'cndrcron',
        :mode   => '0755',
      })
    end

    it do
      should contain_file('/var/log/condor-cron').with({
        :ensure => 'directory',
        :owner  => 'cndrcron',
        :group  => 'cndrcron',
        :mode   => '0755',
      })
    end
  end

  context 'osg::rsv::service' do
    it do
      should contain_service('rsv').with({
        :ensure     => 'running',
        :enable     => 'true',
        :hasstatus  => 'false',
        :hasrestart => 'true',
        :status     => 'test -f /var/lock/subsys/rsv',
      })
    end

    it do
      should contain_service('condor-cron').with({
        :ensure     => 'running',
        :enable     => 'true',
        :hasstatus  => 'true',
        :hasrestart => 'true',
        :before     => 'Service[rsv]',
      })
    end
  end

  context 'with manage_firewall => false' do
    let(:params) {{ :manage_firewall => false }}
    it { should_not contain_firewall('100 allow RSV http access') }
  end

  # Test validate_bool parameters
  [
    'manage_users',
    'with_httpd',
    'manage_firewall',
  ].each do |param|
    context "with #{param} => 'foo'" do
      let(:params) {{ param.to_sym => 'foo' }}
      it { expect { should create_class('osg::rsv') }.to raise_error(Puppet::Error, /is not a boolean/) }
    end
  end
end
