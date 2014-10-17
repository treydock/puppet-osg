require 'spec_helper'

describe 'osg::gums::client' do
  include_context :defaults

  let(:facts) { default_facts }

  it { should create_class('osg::gums::client') }
  it { should contain_class('osg') }

  it do 
    should contain_osg_local_site_settings('Misc Services/gums_host').with({
      :value  => 'gums.example.tld',
    })
  end

  it do
    should contain_service('gums-client-cron').with({
      :ensure      => 'running',
      :enable      => 'true',
      :hasstatus   => 'true',
      :hasrestart  => 'true',
      :require     => 'Osg_config[Misc Services/gums_host]',
    })
  end

  context 'when gums_host defined' do
    let(:pre_condition) { "class { 'osg': gums_host => 'foo.bar' }" }
    it { should contain_osg_local_site_settings('Misc Services/gums_host').with_value('foo.bar') }
  end
end
