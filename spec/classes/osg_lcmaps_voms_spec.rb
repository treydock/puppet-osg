require 'spec_helper'

describe 'osg::lcmaps_voms' do
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
      it { should create_class('osg::lcmaps_voms') }
      it { should contain_class('osg::params') }
      it { should contain_class('osg') }
      it { should contain_class('osg::cacerts') }

      it { should contain_anchor('osg::lcmaps_voms::start').that_comes_before('Class[osg]') }
      it { should contain_class('osg').that_comes_before('Class[osg::cacerts]') }
      it { should contain_class('osg::cacerts').that_comes_before('Class[osg::lcmaps_voms::install]') }
      it { should contain_class('osg::lcmaps_voms::install').that_comes_before('Class[osg::lcmaps_voms::config]') }
      it { should contain_class('osg::lcmaps_voms::config').that_comes_before('Anchor[osg::lcmaps_voms::end]') }
      it { should contain_anchor('osg::lcmaps_voms::end') }

      context 'osg::lcmaps_voms::install' do
        it do
          should contain_package('lcmaps').with({
            :ensure => 'present',
          })
        end

        it do
          should contain_package('vo-client-lcmaps-voms').with({
            :ensure => 'present',
          })
        end

        it do
          should contain_package('osg-configure-misc').with({
            :ensure => 'present',
          })
        end
      end

      context 'osg::lcmaps_voms::config' do
        it do
          should contain_osg_local_site_settings('Misc Services/authorization_method').with_value('vomsmap')
        end
        it do
          should contain_osg_local_site_settings('Misc Services/edit_lcmaps_db').with_value('true')
        end
        it do
          should contain_osg_local_site_settings('Misc Services/gums_host').with_ensure('absent')
        end

        it do
          should contain_concat('/etc/grid-security/voms-mapfile').with({
            :ensure => 'present',
            :owner  => 'root',
            :group  => 'root',
            :mode   => '0644',
            :warn   => 'true',
          })
        end

        it do
          should contain_concat('/etc/grid-security/grid-mapfile').with({
            :ensure => 'present',
            :owner  => 'root',
            :group  => 'root',
            :mode   => '0644',
            :warn   => 'true',
          })
        end

        it do
          verify_exact_contents(catalogue, '/etc/grid-security/ban-voms-mapfile', [])
        end

        it do
          verify_exact_contents(catalogue, '/etc/grid-security/ban-mapfile', [])
        end

        context 'when ban_voms defined' do
          let(:params) do
            {
              :ban_voms => ['/foo'],
            }
          end

          it do
            verify_exact_contents(catalogue, '/etc/grid-security/ban-voms-mapfile', [
              '"/foo"',
            ])
          end
        end

        context 'when ban_users defined' do
          let(:params) do
            {
              :ban_users => ['/foo'],
            }
          end

          it do
            verify_exact_contents(catalogue, '/etc/grid-security/ban-mapfile', [
              '"/foo"',
            ])
          end
        end
      end

      context 'vos defined' do
        let(:params) do
          {
            :vos => { 'foo' => '/bar' }
          }
        end

        it { should contain_osg__lcmaps_voms__vo('foo').with_dn('/bar') }
      end

      context 'vos defined as resource' do
        let(:params) do
          {
            :vos => { 'foo' => {'dn' => '/bar' }}
          }
        end

        it { should contain_osg__lcmaps_voms__vo('foo').with_dn('/bar') }
      end

      context 'users defined' do
        let(:params) do
          {
            :users => { 'foo' => '/bar' }
          }
        end

        it { should contain_osg__lcmaps_voms__user('foo').with_dn('/bar') }
      end

      context 'users defined as resource' do
        let(:params) do
          {
            :users => { 'foo' => {'dn' => '/bar' }}
          }
        end

        it { should contain_osg__lcmaps_voms__user('foo').with_dn('/bar') }
      end

    end
  end
end
