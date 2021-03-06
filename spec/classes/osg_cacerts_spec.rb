require 'spec_helper'

describe 'osg::cacerts' do
  on_supported_os(supported_os: [
                    {
                      'operatingsystem' => 'CentOS',
                      'operatingsystemrelease' => ['7'],
                    },
                  ]).each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to create_class('osg::cacerts') }
      it { is_expected.to contain_class('osg') }
      it { is_expected.to contain_class('osg::fetchcrl') }

      it do
        is_expected.to contain_package('osg-ca-certs').with(ensure: 'installed',
                                                            name: 'osg-ca-certs',
                                                            require: 'Yumrepo[osg]')
      end

      it do
        is_expected.to contain_file('/etc/grid-security').with(ensure: 'directory',
                                                               owner: 'root',
                                                               group: 'root',
                                                               mode: '0755')
      end

      it do
        is_expected.to contain_file('/etc/grid-security/certificates').with(ensure: 'directory',
                                                                            before: 'Package[osg-ca-certs]')
      end

      context 'when osg::cacerts_package_ensure => "latest"' do
        let(:pre_condition) { "class { 'osg': cacerts_package_ensure => 'latest' }" }

        it { is_expected.to contain_package('osg-ca-certs').with_ensure('latest') }
      end

      context 'when osg::cacerts_package_name => "empty-ca-certs"' do
        let(:pre_condition) { "class { 'osg': cacerts_package_name => 'empty-ca-certs' }" }

        it { is_expected.not_to contain_class('osg::fetchcrl') }

        it do
          is_expected.to contain_package('osg-ca-certs').with(ensure: 'installed',
                                                              name: 'empty-ca-certs',
                                                              require: 'Yumrepo[osg]')
        end

        it do
          is_expected.to contain_file('/etc/grid-security/certificates').with(ensure: 'link',
                                                                              target: '/opt/grid-certificates',
                                                                              before: 'Package[osg-ca-certs]')
        end

        context 'when osg::shared_certs_path => /foo/bar' do
          let :pre_condition do
            "class { 'osg':
              cacerts_package_name => 'empty-ca-certs',
              shared_certs_path => '/foo/bar',
            }
            "
          end

          it { is_expected.to contain_file('/etc/grid-security/certificates').with_target('/foo/bar') }
        end
      end

      context 'when osg::cacerts_package_name => "igtf-ca-certs"' do
        let(:pre_condition) { "class { 'osg': cacerts_package_name => 'igtf-ca-certs' }" }

        it do
          is_expected.to contain_package('osg-ca-certs').with(ensure: 'installed',
                                                              name: 'igtf-ca-certs',
                                                              require: 'Yumrepo[osg]')
        end

        it do
          is_expected.to contain_file('/etc/grid-security').with(ensure: 'directory',
                                                                 owner: 'root',
                                                                 group: 'root',
                                                                 mode: '0755')
        end

        it do
          is_expected.to contain_file('/etc/grid-security/certificates').with(ensure: 'directory',
                                                                              before: 'Package[osg-ca-certs]')
        end
      end
    end
  end
end
