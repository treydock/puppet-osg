require 'spec_helper'

describe 'osg::lcmaps' do
  include_context :defaults

  let(:facts) { default_facts }

  let(:params) {{ :gums_hostname => 'gums.foo' }}

  it { should create_class('osg::lcmaps') }
  it { should contain_class('osg::params') }
  it { should contain_class('osg') }

  it do 
    should contain_package('lcmaps').with({
      'ensure'  => 'installed',
      'before'  => 'File[/etc/lcmaps.db]',
      'require' => 'Yumrepo[osg]',
    })
  end

  it do
    should contain_file('/etc/lcmaps.db').with({
      'ensure'  => 'present',
      'replace' => 'true',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
    })
  end

  it do
    verify_contents(catalogue, '/etc/lcmaps.db', [
      '             "--endpoint https://gums.foo:8443/gums/services/GUMSXACMLAuthorizationServicePort"',
      'glexec:',
    ])
  end

  it do
    should contain_file('/etc/grid-security/gsi-authz.conf').with({
      'ensure'  => 'present',
      'replace' => 'true',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
    })
  end

  it do
    content = catalogue.resource('file', '/etc/grid-security/gsi-authz.conf').send(:parameters)[:content]
    content.split("\n").should == [
      '# globus_mapping liblcas_lcmaps_gt4_mapping.so lcmaps_callout',
      'globus_mapping liblcas_lcmaps_gt4_mapping.so lcmaps_callout',
    ]
  end

  context "with no parameters defined" do
    let(:params){{ }}
    it { expect { should create_class('osg::lcmaps') }.to raise_error(Puppet::Error, /Must pass gums_hostname/) }
  end

  context "when lcmaps_package_ensure => 'absent'" do
    let(:params) {{ :gums_hostname => 'gums.foo', :lcmaps_package_ensure => 'absent' }}
    it { should contain_package('lcmaps').with_ensure('absent') }
  end

  context "when lcmaps_globus_package_ensure => 'absent'" do
    let(:params) {{ :gums_hostname => 'gums.foo', :lcmaps_globus_package_ensure => 'absent' }}
    it { should contain_package('lcas-lcmaps-gt4-interface').with_ensure('absent') }
  end

  context "when lcmaps_config_replace => false" do
    let(:params) {{ :gums_hostname => 'gums.foo', :lcmaps_config_replace => false }}
    it { should contain_file('/etc/lcmaps.db').with_replace('false') }
  end

  context "when lcmaps_globus_config_replace => false" do
    let(:params) {{ :gums_hostname => 'gums.foo', :lcmaps_globus_config_replace => false }}
    it { should contain_file('/etc/grid-security/gsi-authz.conf').with_replace('false') }
  end

  context "when gums_port => '7443'" do
    let(:params) {{ :gums_hostname => 'gums.foo', :gums_port => '7443' }}
    it do
      verify_contents(catalogue, '/etc/lcmaps.db', [
        '             "--endpoint https://gums.foo:7443/gums/services/GUMSXACMLAuthorizationServicePort"'
      ])
    end
  end

  context "when with_glexec => false" do
    let(:params) {{ :gums_hostname => 'gums.foo', :with_glexec => false }}
    it { verify_contents(catalogue, '/etc/lcmaps.db', [ '#glexec:' ]) }
  end

  [
    'UNSET',
    'undef',
    false,
  ].each do |v|
    context "when globus_mapping => #{v}" do
      let(:params) {{ :gums_hostname => 'gums.foo', :globus_mapping => v }}
      it do
        content = catalogue.resource('file', '/etc/grid-security/gsi-authz.conf').send(:parameters)[:content]
        content.should match '# globus_mapping liblcas_lcmaps_gt4_mapping.so lcmaps_callout'
      end

      it do
        content = catalogue.resource('file', '/etc/grid-security/gsi-authz.conf').send(:parameters)[:content]
        content.split("\n").should_not == [
          '# globus_mapping liblcas_lcmaps_gt4_mapping.so lcmaps_callout',
          'globus_mapping liblcas_lcmaps_gt4_mapping.so lcmaps_callout',
        ]
      end
    end
  end

  [
    'with_glexec',
    'lcmaps_config_replace',
    'lcmaps_globus_config_replace',
  ].each do |bool_param|
    context "with #{bool_param} => 'foo'" do
      let(:params) {{ :gums_hostname => 'gums.foo', bool_param.to_sym => 'foo' }}
      it { expect { should create_class('osg::lcmaps') }.to raise_error(Puppet::Error, /is not a boolean/) }
    end
  end
end
