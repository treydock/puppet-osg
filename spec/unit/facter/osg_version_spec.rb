require 'spec_helper'

describe 'osg_version fact' do
  before(:each) do
    Facter.clear
    allow(Facter.fact(:osfamily)).to receive(:value).and_return('RedHat')
  end

  after(:each) do
    Facter.clear
  end

  it 'returns correct version 3.2.30' do
    allow(File).to receive(:exists?).with('/etc/osg-version').and_return(true)
    allow(Facter::Core::Execution).to receive(:execute).with('cat /etc/osg-version 2>/dev/null').and_return(my_fixture_read('osg-version-3.2.30'))
    expect(Facter.fact(:osg_version).value).to eq('3.2.30')
  end

  it 'returns nothing if /etc/osg-version is not present' do
    allow(File).to receive(:exists?).with('/etc/osg-version').and_return(false)
    expect(Facter.fact(:osg_version).value).to be_nil
  end
end
