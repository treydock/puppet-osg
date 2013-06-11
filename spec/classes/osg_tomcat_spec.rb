require 'spec_helper'

describe 'osg::tomcat' do

  let :facts do
    RSpec.configuration.default_facts.merge({

    })
  end

  it { should contain_class('osg') }
  it { should include_class('osg::repo') }
  it { should include_class('osg::params') }

  it do 
    should contain_package('tomcat6').with({
      'ensure'  => 'present',
    })
  end

  it do
    should contain_service('tomcat6').with({
      'ensure'      => 'running',
      'enable'      => 'true',
      'hasstatus'   => 'true',
      'hasrestart'  => 'true',
      'require'     => 'Package[tomcat6]',
    })
  end
end
