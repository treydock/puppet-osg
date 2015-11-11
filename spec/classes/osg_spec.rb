require 'spec_helper'

describe 'osg' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({
          :concat_basedir => '/dne',
          :puppetversion => Puppet.version,
        })
      end

      it { should create_class('osg') }
      it { should contain_class('osg::params') }
      it { should contain_class('epel') }
      it { should contain_class('osg::configure') }

      it { should contain_anchor('osg::start').that_comes_before('Class[epel]') }
      it { should contain_class('epel').that_comes_before('Class[osg::repos]') }
      it { should contain_class('osg::repos').that_comes_before('Anchor[osg::end]') }
      it { should contain_anchor('osg::end') }

      # Test validate_re parameters
      context "with osg_release => 'foo'" do
        let(:params) {{ :osg_release => 'foo' }}
        it { expect { should create_class('osg') }.to raise_error(Puppet::Error, /The osg_release parameter only supports 3.2 and 3.3/) }
      end


      context 'when cacerts_package_name => "foo"' do
        let(:params) {{ :cacerts_package_name => 'foo' }}
        it { expect { should create_class('osg') }.to raise_error(Puppet::Error, /does not match "\^\(osg-ca-certs\|igtf-ca-certs\|empty-ca-certs\)\$"/) }
      end

      # Test validate_bool parameters
      [
        'repo_use_mirrors',
        'enable_osg_contrib',
        'cacerts_install_other_packages',
      ].each do |param|
        context "with #{param} => 'foo'" do
          let(:params) {{ param.to_sym => 'foo' }}
          it { expect { should create_class('osg') }.to raise_error(Puppet::Error, /is not a boolean/) }
        end
      end

    end
  end
end
