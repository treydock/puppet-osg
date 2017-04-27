require 'spec_helper'

describe 'osg::wn' do
  on_supported_os({
    :supported_os => [
      {
        "operatingsystem" => "CentOS",
        "operatingsystemrelease" => ["6", "7"],
      }
    ]
  }).each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({
          :concat_basedir => '/dne',
          :puppetversion => Puppet.version,
        })
      end

      let(:params) {{ }}

      it { should compile.with_all_deps }
      it { should create_class('osg::wn') }
      it { should contain_class('osg::params') }

      it { should contain_anchor('osg::wn::start').that_comes_before('Class[osg]') }
      it { should contain_class('osg').that_comes_before('Class[osg::cacerts]') }
      it { should contain_class('osg::cacerts').that_comes_before('Package[osg-wn-client]') }
      it { should contain_package('osg-wn-client').with_ensure('present').that_comes_before('Package[xrootd-client]') }
      it { should contain_package('xrootd-client').with_ensure('present').that_comes_before('Anchor[osg::wn::end]') }
      it { should contain_anchor('osg::wn::end') }

    end
  end
end
