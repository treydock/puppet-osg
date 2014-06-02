require 'spec_helper'

describe 'osg::wn' do
  include_context :defaults

  let(:facts) { default_facts }

  let(:params) {{ }}

  it { should create_class('osg::wn') }
  it { should contain_class('osg::params') }

  it do
    should contain_class('osg::cacerts').with({
      :package_name   => 'empty-ca-certs',
      :package_ensure => 'installed',
    }).that_comes_before('Package[osg-wn-client]')
  end

  it do
    should contain_package('osg-wn-client').with({
      :ensure => 'present',
    }).that_comes_before('Anchor[osg::wn::end]')
  end

  it { should contain_anchor('osg::wn::start').that_comes_before('Class[osg]') }
  it { should contain_class('osg').that_comes_before('Class[osg::cacerts]') }
  it { should contain_anchor('osg::wn::end') }
end
