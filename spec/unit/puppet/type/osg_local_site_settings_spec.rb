require 'spec_helper'

describe Puppet::Type.type(:osg_local_site_settings) do
  let(:osg_local_site_settings) { described_class.new(name: 'vars/foo', value: 'bar') }

  it 'requires a name' do
    expect {
      described_class.new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  it 'does not expect a name with whitespace' do
    expect {
      described_class.new(name: 'f oo')
    }.to raise_error(Puppet::Error, %r{Invalid osg_local_site_settings})
  end

  it 'fails when there is no section' do
    expect {
      described_class.new(name: 'foo')
    }.to raise_error(Puppet::Error, %r{Invalid osg_local_site_settings})
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
    osg_local_site_settings[:value] = 'bar'
    expect(osg_local_site_settings[:value]).to eq('bar')
  end

  it 'does not accept a value with whitespace' do
    osg_local_site_settings[:value] = 'b ar'
    expect(osg_local_site_settings[:value]).to eq('b ar')
  end

  it 'accepts valid ensure values' do
    osg_local_site_settings[:ensure] = :present
    expect(osg_local_site_settings[:ensure]).to eq(:present)
    osg_local_site_settings[:ensure] = :absent
    expect(osg_local_site_settings[:ensure]).to eq(:absent)
  end

  it 'changes true to True' do
    osg_local_site_settings[:value] = true
    expect(osg_local_site_settings[:value]).to eq('True')
  end

  it 'changes false to False' do
    osg_local_site_settings[:value] = false
    expect(osg_local_site_settings[:value]).to eq('False')
  end

  it 'does not accept invalid ensure values' do
    expect {
      osg_local_site_settings[:ensure] = :latest
    }.to raise_error(Puppet::Error, %r{Invalid value})
  end
end
