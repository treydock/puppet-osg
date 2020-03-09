require 'spec_helper'

describe 'osg::cvmfs' do
  on_supported_os(supported_os: [
                    {
                      'operatingsystem' => 'CentOS',
                      'operatingsystemrelease' => ['7'],
                    },
                  ]).each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      let(:params) { {} }

      if facts[:operatingsystemmajrelease].to_i >= 7
        manage_fuse_group = false
        cvmfs_groups      = nil
      else
        manage_fuse_group = true
        cvmfs_groups      = ['fuse']
      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to create_class('osg::cvmfs') }

      it { is_expected.to contain_anchor('osg::cvmfs::start').that_comes_before('Class[osg]') }
      it { is_expected.to contain_class('osg').that_comes_before('Class[osg::cvmfs::user]') }
      it { is_expected.to contain_class('osg::cvmfs::user').that_comes_before('Class[osg::cvmfs::install]') }
      it { is_expected.to contain_class('osg::cvmfs::install').that_comes_before('Class[osg::cvmfs::config]') }
      it { is_expected.to contain_class('osg::cvmfs::config').that_comes_before('Class[osg::cvmfs::service]') }
      it { is_expected.to contain_class('osg::cvmfs::service').that_comes_before('Anchor[osg::cvmfs::end]') }
      it { is_expected.to contain_anchor('osg::cvmfs::end') }

      context 'osg::cvmfs::user' do
        if manage_fuse_group
          it do
            is_expected.to contain_group('fuse').only_with(ensure: 'present',
                                                           name: 'fuse',
                                                           system: 'true',
                                                           forcelocal: 'true',
                                                           before: 'User[cvmfs]')
          end
        else
          it { is_expected.not_to contain_group('fuse') }
        end

        it do
          is_expected.to contain_user('cvmfs').with(ensure: 'present',
                                                    name: 'cvmfs',
                                                    gid: 'cvmfs',
                                                    groups: cvmfs_groups,
                                                    home: '/var/lib/cvmfs',
                                                    shell: '/sbin/nologin',
                                                    system: 'true',
                                                    comment: 'CernVM-FS service account',
                                                    managehome: 'false',
                                                    forcelocal: 'true')
        end

        it do
          is_expected.to contain_group('cvmfs').only_with(ensure: 'present',
                                                          name: 'cvmfs',
                                                          system: 'true',
                                                          forcelocal: 'true')
        end

        context 'with user_uid => 100' do
          let(:params) { { user_uid: 100 } }

          it { is_expected.to contain_user('cvmfs').with_uid('100') }
        end

        context 'with group_gid => 100' do
          let(:params) { { group_gid: 100 } }

          it { is_expected.to contain_group('cvmfs').with_gid('100') }
        end

        context 'with fuse_group_gid => 100' do
          let(:params) { { fuse_group_gid: 99 } }

          if manage_fuse_group
            it { is_expected.to contain_group('fuse').with_gid('99') }
          else
            it { is_expected.not_to contain_group('fuse') }
          end
        end

        context 'with manage_user => false' do
          let(:params) { { manage_user: false } }

          if manage_fuse_group
            it { is_expected.to contain_group('fuse').without_before }
          else
            it { is_expected.not_to contain_group('fuse') }
          end
          it { is_expected.not_to contain_user('cvmfs') }
        end

        context 'with manage_group => false' do
          let(:params) { { manage_group: false } }

          it { is_expected.not_to contain_group('cvmfs') }
        end

        context 'when manage_fuse_group => false' do
          let(:params) { { manage_fuse_group: false } }

          it { is_expected.not_to contain_group('fuse') }
        end
      end

      context 'osg::cvmfs::install' do
        it do
          is_expected.to contain_package('cvmfs').only_with(ensure: 'installed',
                                                            name: 'osg-oasis')
        end

        context "when package_ensure => 'latest'" do
          let(:params) { { package_ensure: 'latest' } }

          it { is_expected.to contain_package('cvmfs').with_ensure('latest') }
        end
      end

      context 'osg::cvmfs::config' do
        it do
          is_expected.to contain_file('/etc/fuse.conf').only_with(ensure: 'file',
                                                                  path: '/etc/fuse.conf',
                                                                  content: "user_allow_other\n",
                                                                  owner: 'root',
                                                                  group: 'root',
                                                                  mode: '0644')
        end

        if facts[:operatingsystemmajrelease].to_i < 7
          it { is_expected.to contain_file('/bin/fusermount').with_mode('4755') }
        else
          it { is_expected.not_to contain_file('/bin/fusermount') }
        end

        it do
          is_expected.to contain_autofs__mount('cvmfs').with(mount: '/cvmfs',
                                                             mapfile: '/etc/auto.cvmfs',
                                                             order: '50')
        end

        it do
          is_expected.to contain_file('/etc/cvmfs/default.local').with(ensure: 'file',
                                                                       path: '/etc/cvmfs/default.local',
                                                                       owner: 'root',
                                                                       group: 'root',
                                                                       mode: '0644')
        end

        it do
          verify_exact_contents(catalogue, '/etc/cvmfs/default.local', [
                                  'CVMFS_REPOSITORIES="`echo $((echo oasis.opensciencegrid.org;echo cms.cern.ch;ls /cvmfs)|sort -u)|tr \' \' ,`"',
                                  'CVMFS_STRICT_MOUNT=no',
                                  'CVMFS_CACHE_BASE=/var/cache/cvmfs',
                                  'CVMFS_QUOTA_LIMIT=20000',
                                  "CVMFS_HTTP_PROXY=\"http://squid.#{facts[:domain]}:3128\"",
                                  'GLITE_VERSION=',
                                ])
        end

        it { is_expected.to contain_file('/etc/cvmfs/domain.d/cern.ch.local').with_ensure('absent') }

        it do
          is_expected.to contain_file('/etc/cvmfs/config.d/cms.cern.ch.local').only_with(ensure: 'absent',
                                                                                         path: '/etc/cvmfs/config.d/cms.cern.ch.local')
        end

        it do
          is_expected.to contain_file('/var/lib/cvmfs').only_with(ensure: 'directory',
                                                                  path: '/var/lib/cvmfs',
                                                                  owner: 'cvmfs',
                                                                  group: 'cvmfs',
                                                                  mode: '0700')
        end

        context 'with strict_mount => true' do
          let(:params) { { strict_mount: true } }

          it do
            verify_contents(catalogue, '/etc/cvmfs/default.local', ['CVMFS_STRICT_MOUNT=yes'])
          end
        end

        context "when repositories => ['grid.cern.ch','cms.cern.ch']" do
          let(:params) { { repositories: ['grid.cern.ch', 'cms.cern.ch'] } }

          it do
            verify_contents(catalogue, '/etc/cvmfs/default.local', ['CVMFS_REPOSITORIES="grid.cern.ch,cms.cern.ch"'])
          end
        end

        context "when cms_local_site => 'T3_FOO'" do
          let(:params) { { cms_local_site: 'T3_FOO' } }

          it do
            is_expected.to contain_file('/etc/cvmfs/config.d/cms.cern.ch.local').only_with(ensure: 'file',
                                                                                           path: '/etc/cvmfs/config.d/cms.cern.ch.local',
                                                                                           content: %r{.*},
                                                                                           owner: 'root',
                                                                                           group: 'root',
                                                                                           mode: '0644',
                                                                                           notify: 'Exec[cvmfs_config reload]')
          end

          it 'exports CMS_LOCAL_SITE' do
            verify_contents(catalogue, '/etc/cvmfs/config.d/cms.cern.ch.local', ['export CMS_LOCAL_SITE=T3_FOO'])
          end
        end

        context "when cern_server_urls => ['someurl', 'anotherurl']" do
          let(:params) { { cern_server_urls: ['someurl', 'anotherurl'] } }

          it do
            is_expected.to contain_file('/etc/cvmfs/domain.d/cern.ch.local').with(ensure: 'file',
                                                                                  path: '/etc/cvmfs/domain.d/cern.ch.local',
                                                                                  owner: 'root',
                                                                                  group: 'root',
                                                                                  mode: '0644')
          end

          it do
            verify_exact_contents(catalogue, '/etc/cvmfs/domain.d/cern.ch.local', [
                                    'CVMFS_SERVER_URL="someurl;anotherurl"',
                                  ])
          end
        end
      end

      context 'osg::cvmfs::service' do
        it do
          is_expected.to contain_exec('cvmfs_config reload').only_with(command: 'cvmfs_config reload',
                                                                       refreshonly: 'true',
                                                                       path: '/usr/bin:/usr/sbin:/bin:/sbin',
                                                                       subscribe: ['File[/etc/cvmfs/default.local]', 'File[/etc/cvmfs/domain.d/cern.ch.local]'])
        end
      end
    end
  end
end
