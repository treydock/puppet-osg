require 'spec_helper'
require 'puppet/type/osg_gip_config'

describe Puppet::Type.type(:osg_gip_config) do
  let(:osg_gip_config) { described_class.new(name: 'vars/foo', value: 'bar') }

  it 'requires a name' do
    expect {
      described_class.new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  it 'does not expect a name with whitespace' do
    expect {
      described_class.new(name: 'f oo')
    }.to raise_error(Puppet::Error, %r{Invalid osg_gip_config})
  end

  it 'fails when there is no section' do
    expect {
      described_class.new(name: 'foo')
    }.to raise_error(Puppet::Error, %r{Invalid osg_gip_config})
  end

  it 'does not require a value when ensure is absent' do
    described_class.new(name: 'vars/foo', ensure: :absent)
  end

  it 'requires a value when ensure is present' do
    expect {
      described_class.new(name: 'vars/foo', ensure: :present)
    }.to raise_error(Puppet::Error, %r{Property value must be set})
  end

  it 'accepts a valid value' do
    osg_gip_config[:value] = 'bar'
    expect(osg_gip_config[:value]).to eq('bar')
  end

  it 'does not accept a value with whitespace' do
    osg_gip_config[:value] = 'b ar'
    expect(osg_gip_config[:value]).to eq('b ar')
  end

  it 'accepts valid ensure values' do
    osg_gip_config[:ensure] = :present
    expect(osg_gip_config[:ensure]).to eq(:present)
    osg_gip_config[:ensure] = :absent
    expect(osg_gip_config[:ensure]).to eq(:absent)
  end

  it 'changes true to True' do
    osg_gip_config[:value] = true
    expect(osg_gip_config[:value]).to eq('True')
  end

  it 'changes false to False' do
    osg_gip_config[:value] = false
    expect(osg_gip_config[:value]).to eq('False')
  end

  it 'does not accept invalid ensure values' do
    expect {
      osg_gip_config[:ensure] = :latest
    }.to raise_error(Puppet::Error, %r{Invalid value})
  end
end
