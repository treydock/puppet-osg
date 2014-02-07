require 'spec_helper_system'

describe 'osg_version tests:' do
  it 'should not be empty' do
    facter(:puppet => true) do |r| do
      r.facts['osg_version'].should_not be_empty
      r.stderr.should be_empty
      r.exit_code.should be_zero
    end
  end
end
