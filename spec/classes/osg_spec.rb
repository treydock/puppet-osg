require 'spec_helper'

describe 'osg' do

  let :facts do
    default_facts.merge({

    })
  end

  it { should contain_class('osg::params') }
  it { should include_class('osg::repo') }
end
