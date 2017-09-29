require 'spec_helper'

describe 'osg' do
  on_supported_os({
    :supported_os => [
      {
        "operatingsystem" => "CentOS",
        "operatingsystemrelease" => ["6", "7"],
      }
    ]
  }).each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { should compile.with_all_deps }
      it { should create_class('osg') }
      it { should contain_class('osg::params') }
      it { should contain_class('epel') }
      it { should contain_class('osg::configure') }

      it { should contain_anchor('osg::start').that_comes_before('Class[osg::repos]') }
      it { should contain_class('osg::repos').that_comes_before('Anchor[osg::end]') }
      it { should contain_anchor('osg::end') }

    end
  end
end
