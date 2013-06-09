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
      'require' => 'Yumrepo[osg]',
    })
  end
end
