require 'spec_helper'

describe 'osg::repo' do
  include_context :defaults

  let(:facts) { default_facts }

  it { should create_class('osg::repo') }
  it { should contain_class('osg') }
  it { should contain_class('osg::params') }
  it { should contain_class('epel') }

  it { should contain_package('yum-plugin-priorities').with_ensure('present') }

  it do
    should contain_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-OSG').with({
      'ensure'  => 'present',
      'source'  => 'puppet:///modules/osg/RPM-GPG-KEY-OSG',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
    })
  end

  it do
    should contain_gpg_key('osg').with({
      'path'    => '/etc/pki/rpm-gpg/RPM-GPG-KEY-OSG',
      'before'  => 'Yumrepo[osg]',
    })
  end

  it do
    should contain_yumrepo('osg').with({
      'baseurl'         => nil,
      'mirrorlist'      => 'http://repo.grid.iu.edu/mirror/3.0/el6/osg-release/x86_64',
      'descr'           => "OSG Software for Enterprise Linux 6 - x86_64",
      'enabled'         => '1',
      'failovermethod'  => 'priority',
      'gpgcheck'        => '1',
      'gpgkey'          => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-OSG',
      'priority'        => '98',
      'require'         => ['Package[yum-plugin-priorities]', 'Yumrepo[epel]'],
    })
  end

  context 'with osg::baseurl => foo' do
    let(:pre_condition) { "class { 'osg': baseurl => 'foo' }" }
    it { should contain_yumrepo('osg').with_baseurl('foo') }
  end

  context 'with osg::mirrorlist => false' do
    let(:pre_condition) { "class { 'osg': mirrorlist => false }" }
    it { should contain_yumrepo('osg').with_mirrorlist(nil) }
  end

  context 'with osg::mirrorlist => "false"' do
    let(:pre_condition) { "class { 'osg': mirrorlist => 'false' }" }
    it { should contain_yumrepo('osg').with_mirrorlist(nil) }
  end

  context 'with osg::mirrorlist => "undef"' do
    let(:pre_condition) { "class { 'osg': mirrorlist => 'undef' }" }
    it { should contain_yumrepo('osg').with_mirrorlist(nil) }
  end

  context 'with osg::osg_release => "3.1"' do
    let(:pre_condition) { "class { 'osg': osg_release => '3.1' }" }
    it { should contain_yumrepo('osg').with_mirrorlist('http://repo.grid.iu.edu/mirror/osg/3.1/el6/release/x86_64') }
  end

  context 'with osg::osg_release => "2"' do
    let(:pre_condition) { "class { 'osg': osg_release => '2' }" }
    it { expect { should contain_yumrepo('osg') }.to raise_error(Puppet::Error, /The \$osg_release parameter only supports 3.0, 3.1, and 3.2/) }
  end
end
