require 'spec_helper'

describe 'osg::cvmfs' do
  include_context :defaults

  let(:facts) { default_facts }

  let(:params) {{ }}

  it { should create_class('osg::cvmfs') }
  it { should contain_class('osg::params') }

  it { should contain_anchor('osg::cvmfs::start').that_comes_before('Class[osg]') }
  it { should contain_class('osg').that_comes_before('Class[osg::cvmfs::user]') }
  it { should contain_class('osg::cvmfs::user').that_comes_before('Class[osg::cvmfs::install]') }
  it { should contain_class('osg::cvmfs::install').that_comes_before('Class[osg::cvmfs::config]') }
  it { should contain_class('osg::cvmfs::config').that_comes_before('Class[osg::cvmfs::service]') }
  it { should contain_class('osg::cvmfs::service').that_comes_before('Anchor[osg::cvmfs::end]') }
  it { should contain_anchor('osg::cvmfs::end') }

  context 'osg::cvmfs::user' do

    it do
      should contain_user('cvmfs').only_with({
        :ensure      => 'present',
        :name        => 'cvmfs',
        :uid         => nil,
        :gid         => 'cvmfs',
        :home        => '/var/lib/cvmfs',
        :shell       => '/sbin/nologin',
        :system      => 'true',
        :comment     => 'CernVM-FS service account',
        :managehome  => 'false',
      })
    end

    it do
      should contain_group('cvmfs').only_with({
        :ensure  => 'present',
        :name    => 'cvmfs',
        :system  => 'true',
      })
    end

    context "with user_uid => 100" do
      let(:params) {{ :user_uid => 100 }}
      it { should contain_user('cvmfs').with_uid('100') }
    end

    context "with group_gid => 100" do
      let(:params) {{ :group_gid => 100 }}
      it { should contain_group('cvmfs').with_gid('100') }
    end

    context "with manage_user => false" do
      let(:params) {{ :manage_user => false }}
      it { should_not contain_user('cvmfs') }
    end

    context "with manage_group => false" do
      let(:params) {{ :manage_group => false }}
      it { should_not contain_group('cvmfs') }
    end
  end

  context 'osg::cvmfs::install' do
    it do
      should contain_package('cvmfs').only_with({
        :ensure  => 'installed',
        :name    => 'osg-oasis',
      })
    end
  end

  context 'osg::cvmfs::config' do
    it do
      should contain_file('/etc/fuse.conf').only_with({
        :ensure   => 'file',
        :path     => '/etc/fuse.conf',
        :content  => "user_allow_other\n",
        :owner    => 'root',
        :group    => 'root',
        :mode     => '0644',
        :notify   => 'Service[autofs]',
      })
    end

    it do
      should contain_file_line('auto.master cvmfs').only_with({
        :ensure => 'present',
        :name   => 'auto.master cvmfs',
        :path   => '/etc/auto.master',
        :line   => '/cvmfs /etc/auto.cvmfs',
        :match  => '^/cvmfs.*',
        :notify => 'Service[autofs]',
      })
    end

    it do
      should contain_file('/etc/cvmfs/default.local').with({
        :ensure  => 'file',
        :path    => '/etc/cvmfs/default.local',
        :owner   => 'root',
        :group   => 'root',
        :mode    => '0644',
      })
    end  

    it do
      content = catalogue.resource('file', '/etc/cvmfs/default.local').send(:parameters)[:content]
      content.split("\n").reject { |c| c =~ /(^#|^$)/ }.should == [
        'CVMFS_REPOSITORIES="`echo $((echo oasis.opensciencegrid.org;echo cms.cern.ch;ls /cvmfs)|sort -u)|tr \' \' ,`"',
        'CVMFS_CACHE_BASE=/var/cache/cvmfs',
        'CVMFS_QUOTA_LIMIT=20000',
        'CVMFS_HTTP_PROXY="http://squid.example.tld:3128"',
      ]
    end

    it do
      should contain_file('/etc/cvmfs/domain.d/cern.ch.local').with({
        :ensure  => 'file',
        :path    => '/etc/cvmfs/domain.d/cern.ch.local',
        :owner   => 'root',
        :group   => 'root',
        :mode    => '0644',
      })
    end

    it do
      content = catalogue.resource('file', '/etc/cvmfs/domain.d/cern.ch.local').send(:parameters)[:content]
      content.split("\n").reject { |c| c =~ /(^#|^$)/ }.should == [
        'CVMFS_SERVER_URL="http://cvmfs-stratum-one.cern.ch:8000/opt/@org@;http://cernvmfs.gridpp.rl.ac.uk:8000/opt/@org@;http://cvmfs.racf.bnl.gov:8000/opt/@org@"',
      ]
    end
  end

  context 'osg::cvmfs::service' do
    it do
      should contain_service('autofs').only_with({
        :ensure     => 'running',
        :enable     => 'true',
        :hasstatus  => 'true',
        :hasrestart => 'true',
        :name       => 'autofs',
      })
    end

    it do
      should contain_exec('cvmfs_config reload').only_with({
        :command      => 'cvmfs_config reload',
        :refreshonly  => 'true',
        :path         => '/usr/bin:/usr/sbin:/bin:/sbin',
        :subscribe    => ['File[/etc/cvmfs/default.local]', 'File[/etc/cvmfs/domain.d/cern.ch.local]'],
      })
    end
  end

  # Verify validate_bool parameters
  [
    'manage_user',
    'manage_group',
  ].each do |bool_param|
    context "with #{bool_param} => 'foo'" do
      let(:params) {{ bool_param.to_sym => 'foo' }}
      it { expect { should create_class('osg::cvmfs') }.to raise_error(Puppet::Error, /is not a boolean/) }
    end
  end

  # Verify validate_array parameters
  [
    'http_proxies',
    'server_urls',
  ].each do |bool_param|
    context "with #{bool_param} => 'foo'" do
      let(:params) {{ bool_param.to_sym => 'foo' }}
      it { expect { should create_class('osg::cvmfs') }.to raise_error(Puppet::Error, /is not an Array/) }
    end
  end
end
