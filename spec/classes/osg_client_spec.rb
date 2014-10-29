require 'spec_helper'

describe 'osg::client' do
  include_context :defaults

  let(:facts) { default_facts }

  let(:params) {{ }}

  it { should create_class('osg::client') }
  it { should contain_class('osg::params') }

  it { should contain_anchor('osg::client::start').that_comes_before('Class[osg]') }
  it { should contain_class('osg').that_comes_before('Class[osg::cacerts]') }
  it { should contain_class('osg::cacerts').that_comes_before('Class[osg::client::install]') }
  it { should contain_class('osg::client::install').that_comes_before('Class[osg::client::config]') }
  it { should contain_class('osg::client::config').that_comes_before('Class[osg::client::service]') }
  it { should contain_class('osg::client::service').that_comes_before('Anchor[osg::client::end]') }
  it { should contain_anchor('osg::client::end') }

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

  context 'osg::client::install' do
    it do
      should contain_package('osg-client').with({
        :ensure => 'present',
      })
    end

    it do
      should contain_package('condor').with({
        :ensure => 'present',
      })
    end

    it do
      should contain_package('htcondor-ce').with({
        :ensure => 'present',
      })
    end

    context 'when with_condor => false' do
      let(:params) {{ :with_condor => false }}
      it { should_not contain_package('condor') }
    end

    context 'when with_condor_ce => false' do
      let(:params) {{ :with_condor_ce => false }}
      it { should_not contain_package('htcondor-ce') }
    end
  end

  context 'osg::client::config' do
    it do
      should contain_file('/etc/profile.d/globus_firewall.sh').with({
        :ensure   => 'file',
        :owner    => 'root',
        :group    => 'root',
        :mode     => '0644',
      })
    end

    it do
      verify_contents(catalogue, '/etc/profile.d/globus_firewall.sh', [
        'export GLOBUS_TCP_PORT_RANGE=40000,41999',
        'export GLOBUS_TCP_SOURCE_RANGE=40000,41999',
      ])
    end

    it do
      should contain_file('/etc/profile.d/globus_firewall.csh').with({
        :ensure   => 'file',
        :owner    => 'root',
        :group    => 'root',
        :mode     => '0644',
      })
    end

    it do
      verify_contents(catalogue, '/etc/profile.d/globus_firewall.csh', [
        'setenv GLOBUS_TCP_PORT_RANGE 40000,41999',
        'setenv GLOBUS_TCP_SOURCE_RANGE 40000,41999',
      ])
    end
=begin
    it do
      should contain_file('/etc/condor/config.d/10firewall_condor.config').with({
        :ensure   => 'file',
        :owner    => 'root',
        :group    => 'root',
        :mode     => '0644',
        :notify   => 'Service[condor]',
      })
    end

    it do
      verify_contents(catalogue, '/etc/condor/config.d/10firewall_condor.config', [
        'LOWPORT=40000',
        'HIGHPORT=41999',
      ])
    end

    it do
      should contain_file_line('condor DAEMON_LIST').with({
        :path    => '/etc/condor/config.d/00personal_condor.config',
        :line    => 'DAEMON_LIST = COLLECTOR, MASTER, NEGOTIATOR, SCHEDD',
        :match   => '^DAEMON_LIST.*',
        :notify  => 'Service[condor]',
      })
    end
=end

    it do
      should contain_file('/etc/condor/config.d/99-local.conf').with({
        :ensure   => 'file',
        :owner    => 'root',
        :group    => 'root',
        :mode     => '0644',
      })
    end

    it do
      verify_contents(catalogue, '/etc/condor/config.d/99-local.conf', [
        'SUBMIT_EXPRS=$(SUBMIT_EXPRS), use_x509userproxy',
        'use_x509userproxy=true',
      ])
    end

    it do
      should contain_file('/etc/condor-ce/config.d/99-local.conf').with({
        :ensure   => 'file',
        :owner    => 'root',
        :group    => 'root',
        :mode     => '0644',
      })
    end

    it do
      verify_contents(catalogue, '/etc/condor-ce/config.d/99-local.conf', [
        'SUBMIT_EXPRS=$(SUBMIT_EXPRS), use_x509userproxy',
        'use_x509userproxy=true',
      ])
    end

    context 'when with_condor => false' do
      let(:params) {{ :with_condor => false }}
      #it { should_not contain_file('/etc/condor/config.d/10firewall_condor.config') }
      #it { should_not contain_file_line('condor DAEMON_LIST') }
      it { should_not contain_file('/etc/condor/config.d/99-local.conf') }
      it { should_not contain_file('/etc/condor-ce/config.d/99-local.conf') }
    end
  end

  context 'osg::client::service' do
    it do
      should contain_service('condor').with({
        :ensure     => 'stopped',
        :enable     => 'false',
        :hasstatus  => 'true',
        :hasrestart => 'true',
      })
    end

    it do
      should contain_service('condor-ce').with({
        :ensure     => 'stopped',
        :enable     => 'false',
        :hasstatus  => 'true',
        :hasrestart => 'true',
      })
    end

    context 'when with_condor => false' do
      let(:params) {{ :with_condor => false }}
      it { should_not contain_service('condor') }
      it { should_not contain_service('condor-ce') }
    end
  end

  # Test validate_bool parameters
  [
    'with_condor',
    'manage_firewall',
  ].each do |param|
    context "with #{param} => 'foo'" do
      let(:params) {{ param.to_sym => 'foo' }}
      it { expect { should create_class('osg::client') }.to raise_error(Puppet::Error, /is not a boolean/) }
    end
  end
end
