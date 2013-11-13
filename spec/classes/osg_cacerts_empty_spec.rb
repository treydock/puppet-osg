require 'spec_helper'

describe 'osg::cacerts::empty' do
  include_context :defaults

  let(:facts) { default_facts }

  it { should create_class('osg::cacerts::empty') }
  it { should contain_class('osg::params') }
  it { should include_class('osg::repo') }

  it do 
    should contain_package('empty-ca-certs').with({
      'ensure'  => 'installed',
      'name'    => 'empty-ca-certs',
      'require' => 'Yumrepo[osg]',
    })
  end

  context 'with package_ensure => "absent"' do
    let(:params) {{ :package_ensure => 'absent' }}
    it { should contain_package('empty-ca-certs').with_ensure('absent') }
  end
end
