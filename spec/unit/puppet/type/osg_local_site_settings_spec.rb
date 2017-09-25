require 'spec_helper'

describe Puppet::Type.type(:osg_local_site_settings) do
  before :each do
    @osg_local_site_settings = described_class.new(:name => 'vars/foo', :value => 'bar')
  end

  it 'should require a name' do
    expect {
      described_class.new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  it 'should not expect a name with whitespace' do
    expect {
      described_class.new(:name => 'f oo')
    }.to raise_error(Puppet::Error, /Invalid osg_local_site_settings/)
  end

  it 'should fail when there is no section' do
    expect {
      described_class.new(:name => 'foo')
    }.to raise_error(Puppet::Error, /Invalid osg_local_site_settings/)
  end

  it 'should not require a value when ensure is absent' do
    described_class.new(:name => 'vars/foo', :ensure => :absent)
  end

  it 'should require a value when ensure is present' do
    expect {
      described_class.new(:name => 'vars/foo', :ensure => :present)
    }.to raise_error(Puppet::Error, /Property value must be set/)
  end

  it 'should accept a valid value' do
    @osg_local_site_settings[:value] = 'bar'
    expect(@osg_local_site_settings[:value]).to eq('bar')
  end

  it 'should not accept a value with whitespace' do
    @osg_local_site_settings[:value] = 'b ar'
    expect(@osg_local_site_settings[:value]).to eq('b ar')
  end

  it 'should accept valid ensure values' do
    @osg_local_site_settings[:ensure] = :present
    expect(@osg_local_site_settings[:ensure]).to eq(:present)
    @osg_local_site_settings[:ensure] = :absent
    expect(@osg_local_site_settings[:ensure]).to eq(:absent)
  end

  it 'should change true to True' do
    @osg_local_site_settings[:value] = true
    expect(@osg_local_site_settings[:value]).to eq('True')
  end

  it 'should change false to False' do
    @osg_local_site_settings[:value] = false
    expect(@osg_local_site_settings[:value]).to eq('False')
  end

  it 'should not accept invalid ensure values' do
    expect {
      @osg_local_site_settings[:ensure] = :latest
    }.to raise_error(Puppet::Error, /Invalid value/)
  end

end
