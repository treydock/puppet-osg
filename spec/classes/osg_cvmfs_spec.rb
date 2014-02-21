require 'spec_helper'

describe 'osg::cvmfs' do
  include_context :defaults

  let(:facts) { default_facts }

  let(:params) {{ }}

  it { should create_class('osg::cvmfs') }
  it { should contain_class('osg::params') }
  it { should contain_class('osg') }

  it do
    should contain_user('cvmfs').with({
      'ensure'      => 'present',
      'name'        => 'cvmfs',
      'uid'         => nil,
      'home'        => '/var/lib/cvmfs',
      'shell'       => '/sbin/nologin',
      'system'      => 'true',
      'comment'     => 'CernVM-FS service account',
      'managehome'  => 'false',
      'before'      => 'Package[cvmfs]',
    })
  end

  it do
    should contain_group('cvmfs').with({
      'ensure'  => 'present',
      'name'    => 'cvmfs',
      'gid'     => nil,
      'system'  => 'true',
      'before'  => 'Package[cvmfs]',
    })
  end

  it { should contain_package('cvmfs').that_comes_before('File[/etc/fuse.conf]') }
  it { should contain_file('/etc/fuse.conf').that_comes_before('File_line[auto.master cvmfs]') }
  it { should contain_file_line('auto.master cvmfs').that_comes_before('Service[autofs]') }
  it { should contain_file_line('auto.master cvmfs').that_notifies('Service[autofs]') }

  it do
    should contain_package('cvmfs').with({
      'ensure'  => 'installed',
      'name'    => 'osg-oasis',
      'require' => 'Yumrepo[osg]',
    })
  end

  it do
    should contain_file('/etc/fuse.conf').with({
      'ensure'  => 'present',
      'path'    => '/etc/fuse.conf',
      'content' => 'user_allow_other\n',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
    })
  end

  it do
    should contain_file_line('auto.master cvmfs').with({
      'ensure'  => 'present',
      'path'    => '/etc/auto.master',
      'line'    => '/cvmfs /etc/auto.cvmfs',
      'match'   => '^/cvmfs.*',
    })
  end

  it do
    should contain_service('autofs').with({
      'ensure'      => 'running',
      'enable'      => 'true',
      'hasstatus'   => 'true',
      'hasrestart'  => 'true',
    })
  end

  it do
    should contain_file('/etc/cvmfs/default.local').with({
      'ensure'  => 'present',
      'path'    => '/etc/cvmfs/default.local',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
    })
  end  

  it do
    content = catalogue.resource('file', '/etc/cvmfs/default.local').send(:parameters)[:content]
    content.split("\n").reject { |c| c =~ /(^#|^$)/ }.should == [
      'CVMFS_REPOSITORIES="`echo $((echo oasis.opensciencegrid.org;echo cms.cern.ch;ls /cvmfs)|sort -u)|tr \' \' ,`"',
      'CVMFS_CACHE_BASE=/var/cache/cvmfs',
      'CVMFS_QUOTA_LIMIT=20000',
      'CVMFS_HTTP_PROXY="DIRECT"',
    ]
  end

  it do
    should contain_file('/etc/cvmfs/domain.d/cern.ch.local').with({
      'ensure'  => 'present',
      'path'    => '/etc/cvmfs/domain.d/cern.ch.local',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
    })
  end

  it do
    content = catalogue.resource('file', '/etc/cvmfs/domain.d/cern.ch.local').send(:parameters)[:content]
    content.split("\n").reject { |c| c =~ /(^#|^$)/ }.should == [
      'CVMFS_SERVER_URL="http://cvmfs-stratum-one.cern.ch:8000/opt/@org@;http://cernvmfs.gridpp.rl.ac.uk:8000/opt/@org@;http://cvmfs.racf.bnl.gov:8000/opt/"',
    ]
  end

  it do
    should contain_exec('cvmfs_config reload').with({
      'refreshonly' => 'true',
      'path'        => '/usr/bin:/usr/sbin:/bin:/sbin',
      'subscribe'   => ['File[/etc/cvmfs/default.local]', 'File[/etc/cvmfs/domain.d/cern.ch.local]'],
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

  [
    'manage_user',
    'manage_group',
  ].each do |bool_param|
    context "with #{bool_param} => 'foo'" do
      let(:params) {{ bool_param.to_sym => 'foo' }}
      it { expect { should create_class('osg::cvmfs') }.to raise_error(Puppet::Error, /is not a boolean/) }
    end
  end
end
