require 'spec_helper'

describe 'osg::cacerts' do
  include_context :defaults

  let(:facts) { default_facts }

  it { should create_class('osg::cacerts') }
  it { should contain_class('osg::params') }
  it { should include_class('osg::repo') }

  it do 
    should contain_package('osg-ca-certs').with({
      'ensure'  => 'installed',
      'name'    => 'osg-ca-certs',
      'require' => 'Yumrepo[osg]',
    })
  end

  context 'with package_ensure => "latest"' do
    let(:params) {{ :package_ensure => 'latest' }}
    it { should contain_package('osg-ca-certs').with_ensure('latest') }
  end
end
