require 'spec_helper'

describe 'osg' do
  include_context :defaults

  let :facts do
    default_facts.merge({

    })
  end

  it { should contain_class('osg::params') }
  it { should contain_class('osg::repo') }
end
