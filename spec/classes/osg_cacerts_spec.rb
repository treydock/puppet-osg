require 'spec_helper'

describe 'osg::cacerts' do

  let :facts do
    RSpec.configuration.default_facts.merge({

    })
  end

  it { should contain_class('osg') }
  it { should include_class('osg::repo') }

  it do 
    should contain_package('osg-ca-certs').with({
      'ensure'  => 'latest',
      'name'    => 'osg-ca-certs',
      'require' => 'Yumrepo[osg]',
    })
  end

  it do 
    should contain_package('fetch-crl').with({
      'ensure'  => 'installed',
      'name'    => 'fetch-crl',
      'require' => 'Yumrepo[osg]',
    })
  end

  it do
    should contain_service('fetch-crl-boot').with({
      'ensure'      => 'running',
      'enable'      => 'true',
      'hasstatus'   => 'true',
      'hasrestart'  => 'true',
      'require'     => 'Package[fetch-crl]',
    })
  end

  it do
    should contain_service('fetch-crl-cron').with({
      'ensure'      => 'running',
      'enable'      => 'true',
      'hasstatus'   => 'true',
      'hasrestart'  => 'true',
      'require'     => 'Package[fetch-crl]',
    })
  end
end
