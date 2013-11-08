require 'spec_helper'

describe 'osg::cacerts::igtf' do

  let(:facts) { default_facts }

  it { should create_class('osg::cacerts::igtf') }
  it { should contain_class('osg::params') }
  it { should include_class('osg::repo') }

  it do 
    should contain_package('igtf-ca-certs').with({
      'ensure'  => 'installed',
      'name'    => 'igtf-ca-certs',
      'require' => 'Yumrepo[osg]',
    })
  end

  context 'with package_ensure => "absent"' do
    let(:params) {{ :package_ensure => 'absent' }}
    it { should contain_package('igtf-ca-certs').with_ensure('absent') }
  end
end
