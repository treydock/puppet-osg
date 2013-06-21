require 'spec_helper'

describe 'osg::repo' do

  let :facts do
    default_facts.merge({

    })
  end

  it { should contain_class('osg') }
  it { should include_class('osg::params') }
  it { should include_class('epel') }

  it { should contain_package('yum-plugin-priorities').with_ensure('present') }

  it do
    should contain_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-OSG').with({
      'ensure'  => 'present',
      'source'  => 'puppet:///modules/osg/RPM-GPG-KEY-OSG',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
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
    })
  end

  context 'with baseurl => foo' do
    let(:params) {{ :baseurl => 'foo' }}

    it { should contain_yumrepo('osg').with_baseurl('foo') }
  end

  context 'with mirrorlist => false' do
    let(:params) {{ :mirrorlist => false }}

    it { should contain_yumrepo('osg').with_mirrorlist(nil) }
  end

  context 'with mirrorlist => "false"' do
    let(:params) {{ :mirrorlist => 'false' }}

    it { should contain_yumrepo('osg').with_mirrorlist(nil) }
  end

  context 'with mirrorlist => "undef"' do
    let(:params) {{ :mirrorlist => 'undef' }}

    it { should contain_yumrepo('osg').with_mirrorlist(nil) }
  end
end
