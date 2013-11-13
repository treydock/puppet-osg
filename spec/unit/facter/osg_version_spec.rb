require 'facter/osg_version'
require 'spec_helper'

describe 'osg_version fact' do
  include_context :defaults

  before do
    Facter.clear
  end

  after do
    Facter.clear
  end
  
  before :each do
    Facter.fact(:osfamily).stubs(:value).returns(default_facts[:osfamily])
  end

  it "should return correct version 3.1.19" do
    Facter::Util::FileRead.expects(:read).with('/etc/osg-version').returns(my_fixture_read('osg-version-3.1.19'))
    Facter.fact(:osg_version).value.should == '3.1.19'
  end

  it "should return nothing if /etc/osg-version is not present" do
    Facter::Util::Resolution.any_instance.stubs(:warn)
    Facter::Util::FileRead.stubs(:read).with('/etc/osg-version').raises(Errno::ENOENT)
    Facter.fact(:osg_version).value.should == nil
  end
end
