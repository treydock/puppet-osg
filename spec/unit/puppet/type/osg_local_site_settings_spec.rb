require 'puppet'
require 'puppet/type/osg_local_site_settings'

describe 'Puppet::Type.type(:osg_local_site_settings)' do
  before :each do
    @osg_local_site_settings = Puppet::Type.type(:osg_local_site_settings).new(:name => 'vars/foo', :value => 'bar')
  end

  it 'should require a name' do
    expect {
      Puppet::Type.type(:osg_local_site_settings).new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  it 'should not expect a name with whitespace' do
    expect {
      Puppet::Type.type(:osg_local_site_settings).new(:name => 'f oo')
    }.to raise_error(Puppet::Error, /Invalid osg_local_site_settings/)
  end

  it 'should fail when there is no section' do
    expect {
      Puppet::Type.type(:osg_local_site_settings).new(:name => 'foo')
    }.to raise_error(Puppet::Error, /Invalid osg_local_site_settings/)
  end

  it 'should not require a value when ensure is absent' do
    Puppet::Type.type(:osg_local_site_settings).new(:name => 'vars/foo', :ensure => :absent)
  end

  it 'should require a value when ensure is present' do
    expect {
      Puppet::Type.type(:osg_local_site_settings).new(:name => 'vars/foo', :ensure => :present)
    }.to raise_error(Puppet::Error, /Property value must be set/)
  end

  it 'should accept a valid value' do
    @osg_local_site_settings[:value] = 'bar'
    @osg_local_site_settings[:value].should == 'bar'
  end

  it 'should not accept a value with whitespace' do
    @osg_local_site_settings[:value] = 'b ar'
    @osg_local_site_settings[:value].should == 'b ar'
  end

  it 'should accept valid ensure values' do
    @osg_local_site_settings[:ensure] = :present
    @osg_local_site_settings[:ensure].should == :present
    @osg_local_site_settings[:ensure] = :absent
    @osg_local_site_settings[:ensure].should == :absent
  end

  it 'should change true to True' do
    @osg_local_site_settings[:value] = true
    @osg_local_site_settings[:value].should == 'True'
  end

  it 'should change false to False' do
    @osg_local_site_settings[:value] = false
    @osg_local_site_settings[:value].should == 'False'
  end

  it 'should not accept invalid ensure values' do
    expect {
      @osg_local_site_settings[:ensure] = :latest
    }.to raise_error(Puppet::Error, /Invalid value/)
  end

end
