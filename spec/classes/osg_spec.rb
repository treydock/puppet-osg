require 'spec_helper'

describe 'osg' do

  let :facts do
    RSpec.configuration.default_facts.merge({

    })
  end

  it { should contain_class('osg::params') }

end
