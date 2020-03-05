require 'spec_helper'

describe 'osg::wn' do
  on_supported_os(supported_os: [
                    {
                      'operatingsystem' => 'CentOS',
                      'operatingsystemrelease' => ['6', '7'],
                    },
                  ]).each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      let(:params) { {} }

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to create_class('osg::wn') }
      it { is_expected.to contain_class('osg::params') }

      it { is_expected.to contain_anchor('osg::wn::start').that_comes_before('Class[osg]') }
      it { is_expected.to contain_class('osg').that_comes_before('Class[osg::cacerts]') }
      it { is_expected.to contain_class('osg::cacerts').that_comes_before('Package[osg-wn-client]') }
      it { is_expected.to contain_package('osg-wn-client').with_ensure('present').that_comes_before('Package[xrootd-client]') }
      it { is_expected.to contain_package('xrootd-client').with_ensure('present').that_comes_before('Anchor[osg::wn::end]') }
      it { is_expected.to contain_anchor('osg::wn::end') }
    end
  end
end
