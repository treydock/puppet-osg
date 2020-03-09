require 'spec_helper'

describe 'osg' do
  on_supported_os(supported_os: [
                    {
                      'operatingsystem' => 'CentOS',
                      'operatingsystemrelease' => ['7'],
                    },
                  ]).each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to create_class('osg') }
      it { is_expected.to contain_class('epel') }
      it { is_expected.to contain_class('osg::configure') }

      it { is_expected.to contain_anchor('osg::start').that_comes_before('Class[osg::repos]') }
      it { is_expected.to contain_class('osg::repos').that_comes_before('Anchor[osg::end]') }
      it { is_expected.to contain_anchor('osg::end') }
    end
  end
end
