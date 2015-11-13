require 'spec_helper'

describe 'osg::cacerts' do
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

      it { should create_class('osg::cacerts') }
      it { should contain_class('osg::params') }
      it { should contain_class('osg') }

      it do 
        should contain_package('osg-ca-certs').with({
          :ensure   => 'installed',
          :name     => 'osg-ca-certs',
          :require  => 'Yumrepo[osg]',
        })
      end

      it { should_not contain_package('cilogon-ca-certs') }

      it do
        should contain_file('/etc/grid-security').with({
          :ensure => 'directory',
          :owner  => 'root',
          :group  => 'root',
          :mode   => '0755',
          :before => 'File[/etc/grid-security/certificates]',
        })
      end

      it do
        should contain_file('/etc/grid-security/certificates').with({
          :ensure => 'directory',
          :before => 'Package[osg-ca-certs]',
        })
      end

      context 'when osg::cacerts_package_ensure => "latest"' do
        let(:pre_condition) { "class { 'osg': cacerts_package_ensure => 'latest' }" }
        it { should contain_package('osg-ca-certs').with_ensure('latest') }
      end

      context 'when osg::cacerts_package_name => "empty-ca-certs"' do
        let(:pre_condition) { "class { 'osg': cacerts_package_name => 'empty-ca-certs' }" }

        it do 
          should contain_package('osg-ca-certs').with({
            :ensure   => 'installed',
            :name     => 'empty-ca-certs',
            :require  => 'Yumrepo[osg]',
          })
        end

        it do
          should contain_file('/etc/grid-security/certificates').with({
            :ensure => 'link',
            :target => '/opt/grid-certificates',
            :before => 'Package[osg-ca-certs]',
          })
        end

        context 'when osg::shared_certs_path => /foo/bar' do
          let :pre_condition do
            "class { 'osg':
              cacerts_package_name => 'empty-ca-certs',
              shared_certs_path => '/foo/bar',
            }
            "
          end

          it { should contain_file('/etc/grid-security/certificates').with_target('/foo/bar') }
        end
      end

      context 'when osg::cacerts_package_name => "igtf-ca-certs"' do
        let(:pre_condition) { "class { 'osg': cacerts_package_name => 'igtf-ca-certs' }" }

        it do 
          should contain_package('osg-ca-certs').with({
            :ensure   => 'installed',
            :name     => 'igtf-ca-certs',
            :require  => 'Yumrepo[osg]',
          })
        end

        it do
          should contain_file('/etc/grid-security').with({
            :ensure => 'directory',
            :owner  => 'root',
            :group  => 'root',
            :mode   => '0755',
            :before => 'File[/etc/grid-security/certificates]',
          })
        end

        it do
          should contain_file('/etc/grid-security/certificates').with({
            :ensure => 'directory',
            :before => 'Package[osg-ca-certs]',
          })
        end
      end

      context 'when osg::cacerts_install_other_packages => true' do
        let(:pre_condition) { "class { 'osg': cacerts_install_other_packages => true }" }

        it do
          should contain_package('cilogon-ca-certs').with({
            :ensure   => 'latest',
            :require  => 'Yumrepo[osg]',
          })
        end

        context 'when osg::cacerts_other_packages_ensure => "present"' do
          let(:pre_condition) {
            "class { 'osg': cacerts_install_other_packages => true, cacerts_other_packages_ensure => 'present' }"
          }

          it do
            should contain_package('cilogon-ca-certs').with({
              :ensure   => 'present',
              :require  => 'Yumrepo[osg]',
            })
          end
        end
      end

    end
  end
end
