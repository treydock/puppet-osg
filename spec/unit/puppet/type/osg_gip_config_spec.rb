require 'puppet'
require 'puppet/type/osg_gip_config'

describe 'Puppet::Type.type(:osg_gip_config)' do
  before :each do
    @osg_gip_config = Puppet::Type.type(:osg_gip_config).new(:name => 'vars/foo', :value => 'bar')
  end

  it 'should require a name' do
    expect {
      Puppet::Type.type(:osg_gip_config).new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  it 'should not expect a name with whitespace' do
    expect {
      Puppet::Type.type(:osg_gip_config).new(:name => 'f oo')
    }.to raise_error(Puppet::Error, /Invalid osg_gip_config/)
  end

  it 'should fail when there is no section' do
    expect {
      Puppet::Type.type(:osg_gip_config).new(:name => 'foo')
    }.to raise_error(Puppet::Error, /Invalid osg_gip_config/)
  end

  it 'should not require a value when ensure is absent' do
    Puppet::Type.type(:osg_gip_config).new(:name => 'vars/foo', :ensure => :absent)
  end

  it 'should require a value when ensure is present' do
    expect {
      Puppet::Type.type(:osg_gip_config).new(:name => 'vars/foo', :ensure => :present)
    }.to raise_error(Puppet::Error, /Property value must be set/)
  end

  it 'should accept a valid value' do
    @osg_gip_config[:value] = 'bar'
    expect(@osg_gip_config[:value]).to eq('bar')
  end

  it 'should not accept a value with whitespace' do
    @osg_gip_config[:value] = 'b ar'
    expect(@osg_gip_config[:value]).to eq('b ar')
  end

  it 'should accept valid ensure values' do
    @osg_gip_config[:ensure] = :present
    expect(@osg_gip_config[:ensure]).to eq(:present)
    @osg_gip_config[:ensure] = :absent
    expect(@osg_gip_config[:ensure]).to eq(:absent)
  end

  it 'should change true to True' do
    @osg_gip_config[:value] = true
    expect(@osg_gip_config[:value]).to eq('True')
  end

  it 'should change false to False' do
    @osg_gip_config[:value] = false
    expect(@osg_gip_config[:value]).to eq('False')
  end

  it 'should not accept invalid ensure values' do
    expect {
      @osg_gip_config[:ensure] = :latest
    }.to raise_error(Puppet::Error, /Invalid value/)
  end

end
