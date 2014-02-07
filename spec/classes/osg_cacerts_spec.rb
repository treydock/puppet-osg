require 'spec_helper'

describe 'osg::cacerts' do
  include_context :defaults

  let(:facts) { default_facts }

  it { should create_class('osg::cacerts') }
  it { should contain_class('osg::params') }
  it { should contain_class('osg::repo') }

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
  
  context 'when package_name => "empty-ca-certs"' do
    let(:params) {{ :package_name => 'empty-ca-certs' }}

    it do 
      should contain_package('osg-ca-certs').with({
        'ensure'  => 'installed',
        'name'    => 'empty-ca-certs',
        'require' => 'Yumrepo[osg]',
      })
    end
  end

  context 'when package_name => "igtf-ca-certs"' do
    let(:params) {{ :package_name => 'igtf-ca-certs' }}

    it do 
      should contain_package('osg-ca-certs').with({
        'ensure'  => 'installed',
        'name'    => 'igtf-ca-certs',
        'require' => 'Yumrepo[osg]',
      })
    end
  end

  context 'when package_name => "foo"' do
    let(:params) {{ :package_name => 'foo' }}
    it { expect { should contain_package('osg-ca-certs') }.to raise_error(Puppet::Error, /does not match "\^\(osg-ca-certs\|igtf-ca-certs\|empty-ca-certs\)\$"/) }
  end
end
