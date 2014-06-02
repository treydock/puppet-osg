require 'spec_helper'

describe 'osg' do
  include_context :defaults

  let(:facts) { default_facts }

  it { should create_class('osg') }
  it { should contain_class('osg::params') }
  it { should contain_class('epel') }
  it { should contain_class('osg::configure') }

  it { should contain_anchor('osg::start').that_comes_before('Yumrepo[epel]') }
  it { should contain_yumrepo('epel').that_comes_before('Class[osg::repos]') }
  it { should contain_class('osg::repos').that_comes_before('Anchor[osg::end]') }
  it { should contain_anchor('osg::end') }

  # Test validate_re parameters
  context "with osg_release => 'foo'" do
    let(:params) {{ :osg_release => 'foo' }}
    it { expect { should create_class('osg') }.to raise_error(Puppet::Error, /The osg_release parameter only supports 3.1 and 3.2/) }
  end

  # Test validate_bool parameters
  [
    'repo_use_mirrors',
    'enable_osg_contrib',
  ].each do |param|
    context "with #{param} => 'foo'" do
      let(:params) {{ param.to_sym => 'foo' }}
      it { expect { should create_class('osg') }.to raise_error(Puppet::Error, /is not a boolean/) }
    end
  end
end
