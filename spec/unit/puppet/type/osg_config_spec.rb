require 'puppet'
require 'puppet/type/osg_config'

describe 'Puppet::Type.type(:osg_config)' do
  before :each do
    @osg_config = Puppet::Type.type(:osg_config).new(:name => 'vars/foo', :value => 'bar', :path => '01-baz.ini')
  end

  it 'should require a name' do
    expect {
      Puppet::Type.type(:osg_config).new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  it 'should not expect a name with whitespace' do
    expect {
      Puppet::Type.type(:osg_config).new(:name => 'f oo')
    }.to raise_error(Puppet::Error, /Invalid osg_config/)
  end

  it 'should fail when there is no section' do
    expect {
      Puppet::Type.type(:osg_config).new(:name => 'foo')
    }.to raise_error(Puppet::Error, /Invalid osg_config/)
  end

  it 'should not require a value when ensure is absent' do
    Puppet::Type.type(:osg_config).new(:name => 'vars/foo', :ensure => :absent)
  end

  it 'should require a value when ensure is present' do
    expect {
      Puppet::Type.type(:osg_config).new(:name => 'vars/foo', :ensure => :present)
    }.to raise_error(Puppet::Error, /Property value must be set/)
  end

  it 'should accept a valid value' do
    @osg_config[:value] = 'bar'
    @osg_config[:value].should == 'bar'
  end

  it 'should not accept a value with whitespace' do
    @osg_config[:value] = 'b ar'
    @osg_config[:value].should == 'b ar'
  end

  it 'should accept valid ensure values' do
    @osg_config[:ensure] = :present
    @osg_config[:ensure].should == :present
    @osg_config[:ensure] = :absent
    @osg_config[:ensure].should == :absent
  end

  it 'should not accept invalid ensure values' do
    expect {
      @osg_config[:ensure] = :latest
    }.to raise_error(Puppet::Error, /Invalid value/)
  end

end
