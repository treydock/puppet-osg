require 'spec_helper'

describe 'osg::rsv' do
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
      it { is_expected.to create_class('osg::rsv') }
      it { is_expected.to contain_class('osg::params') }

      it { is_expected.to contain_anchor('osg::rsv::start').that_comes_before('Class[osg]') }
      it { is_expected.to contain_class('osg').that_comes_before('Class[osg::cacerts]') }
      it { is_expected.to contain_class('osg::cacerts').that_comes_before('Class[osg::rsv::users]') }
      it { is_expected.to contain_class('osg::rsv::users').that_comes_before('Class[osg::rsv::install]') }
      it { is_expected.to contain_class('osg::rsv::install').that_comes_before('Class[osg::rsv::config]') }
      it { is_expected.to contain_class('osg::rsv::config').that_notifies('Class[osg::rsv::service]') }
      it { is_expected.to contain_class('osg::rsv::service').that_comes_before('Anchor[osg::rsv::end]') }
      it { is_expected.to contain_anchor('osg::rsv::end') }

      it do
        is_expected.to contain_firewall('100 allow RSV http access').with(ensure: 'present',
                                                                          dport: '80',
                                                                          proto: 'tcp',
                                                                          action: 'accept')
      end

      it { is_expected.to contain_class('apache') }

      it do
        is_expected.to contain_file('/etc/httpd/conf.d/rsv.conf').with(ensure: 'file',
                                                                       owner: 'root',
                                                                       group: 'root',
                                                                       mode: '0644',
                                                                       require: 'Package[httpd]',
                                                                       notify: 'Service[httpd]')
      end

      if facts[:operatingsystemmajrelease] == '7'
        it do
          verify_contents(catalogue, '/etc/httpd/conf.d/rsv.conf', [
                            '<Directory "/usr/share/rsv/www">',
                            '    Options None',
                            '    AllowOverride None',
                            '    Require all granted',
                            '</Directory>',
                            'Alias /rsv /usr/share/rsv/www',
                          ])
        end
      else
        it do
          verify_contents(catalogue, '/etc/httpd/conf.d/rsv.conf', [
                            '<Directory "/usr/share/rsv/www">',
                            '    Options None',
                            '    AllowOverride None',
                            '    Order Allow,Deny',
                            '    Allow from all',
                            '</Directory>',
                            'Alias /rsv /usr/share/rsv/www',
                          ])
        end
      end

      context 'osg::rsv::install' do
        it do
          is_expected.to contain_package('rsv').with(ensure: 'installed')
        end
      end

      context 'osg::rsv::users' do
        it do
          is_expected.to contain_user('rsv').with(ensure: 'present',
                                                  name: 'rsv',
                                                  uid: nil,
                                                  gid: 'rsv',
                                                  home: '/var/rsv',
                                                  shell: '/bin/sh',
                                                  system: 'true',
                                                  comment: 'RSV monitoring',
                                                  managehome: 'false')
        end

        it do
          is_expected.to contain_group('rsv').with(ensure: 'present',
                                                   name: 'rsv',
                                                   gid: nil,
                                                   system: 'true')
        end

        it do
          is_expected.to contain_user('cndrcron').with(ensure: 'present',
                                                       name: 'cndrcron',
                                                       uid: '93',
                                                       gid: 'cndrcron',
                                                       home: '/var/lib/condor-cron',
                                                       shell: '/sbin/nologin',
                                                       system: 'true',
                                                       comment: 'Condor-cron service',
                                                       managehome: 'false')
        end

        it do
          is_expected.to contain_group('cndrcron').with(ensure: 'present',
                                                        name: 'cndrcron',
                                                        gid: '93',
                                                        system: 'true')
        end

        context 'when UID / GID defined for RSV' do
          let(:params) { { rsv_uid: 999, rsv_gid: 999 } }

          it { is_expected.to contain_user('rsv').with_uid('999') }
          it { is_expected.to contain_group('rsv').with_gid('999') }
        end

        context 'when manages_users => false' do
          let(:params) { { manage_users: false } }

          it { is_expected.not_to contain_user('rsv') }
          it { is_expected.not_to contain_group('rsv') }
          it { is_expected.not_to contain_user('cndrcron') }
          it { is_expected.not_to contain_group('cndrcron') }
        end
      end

      context 'osg::rsv::config' do
        [
          { name: 'RSV/ce_hosts', value: 'UNAVAILABLE' },
          { name: 'RSV/gram_ce_hosts', value: 'UNAVAILABLE' },
          { name: 'RSV/htcondor_ce_hosts', value: 'UNAVAILABLE' },
          { name: 'RSV/gridftp_hosts', value: 'UNAVAILABLE' },
          { name: 'RSV/gridftp_dir', value: 'DEFAULT' },
          { name: 'RSV/gratia_probes', value: 'DEFAULT' },
          { name: 'RSV/srm_hosts', value: 'UNAVAILABLE' },
          { name: 'RSV/srm_dir', value: 'DEFAULT' },
          { name: 'RSV/srm_webservice_path', value: 'DEFAULT' },
        ].each do |h|
          it do
            is_expected.to contain_osg_local_site_settings(h[:name]).with(value: h[:value])
          end
        end

        it do
          is_expected.to contain_file('/etc/grid-security/rsv').with(ensure: 'directory',
                                                                     owner: 'root',
                                                                     group: 'root',
                                                                     mode: '0755')
        end

        it do
          is_expected.to contain_file('/etc/grid-security/rsv/rsvcert.pem').with(ensure: 'file',
                                                                                 owner: 'rsv',
                                                                                 group: 'rsv',
                                                                                 mode: '0444',
                                                                                 source: nil,
                                                                                 show_diff: 'false')
        end

        it do
          is_expected.to contain_file('/etc/grid-security/rsv/rsvkey.pem').with(ensure: 'file',
                                                                                owner: 'rsv',
                                                                                group: 'rsv',
                                                                                mode: '0400',
                                                                                source: nil,
                                                                                show_diff: 'false')
        end

        it do
          is_expected.to contain_file('/var/spool/rsv').with(ensure: 'directory',
                                                             owner: 'rsv',
                                                             group: 'rsv',
                                                             mode: '0755')
        end

        it do
          is_expected.to contain_file('/var/log/rsv').with(ensure: 'directory',
                                                           owner: 'rsv',
                                                           group: 'rsv',
                                                           mode: '0755')
        end

        it do
          is_expected.to contain_file('/var/log/rsv/consumers').with(ensure: 'directory',
                                                                     owner: 'rsv',
                                                                     group: 'rsv',
                                                                     mode: '0755',
                                                                     require: 'File[/var/log/rsv]')
        end

        it do
          is_expected.to contain_file('/var/log/rsv/metrics').with(ensure: 'directory',
                                                                   owner: 'rsv',
                                                                   group: 'rsv',
                                                                   mode: '0755',
                                                                   require: 'File[/var/log/rsv]')
        end

        it do
          is_expected.to contain_file('/etc/condor-cron/config.d/condor_ids').with(ensure: 'file',
                                                                                   owner: 'root',
                                                                                   group: 'root',
                                                                                   mode: '0644')
        end

        it do
          verify_contents(catalogue, '/etc/condor-cron/config.d/condor_ids', [
                            'CONDOR_IDS = 93.93',
                          ])
        end

        it do
          is_expected.to contain_file('/var/lib/condor-cron').with(ensure: 'directory',
                                                                   owner: 'cndrcron',
                                                                   group: 'cndrcron',
                                                                   mode: '0755')
        end

        it do
          is_expected.to contain_file('/var/lib/condor-cron/execute').with(ensure: 'directory',
                                                                           owner: 'cndrcron',
                                                                           group: 'cndrcron',
                                                                           mode: '0755',
                                                                           require: 'File[/var/lib/condor-cron]')
        end

        it do
          is_expected.to contain_file('/var/lib/condor-cron/spool').with(ensure: 'directory',
                                                                         owner: 'cndrcron',
                                                                         group: 'cndrcron',
                                                                         mode: '0755',
                                                                         require: 'File[/var/lib/condor-cron]')
        end

        it do
          is_expected.to contain_file('/var/run/condor-cron').with(ensure: 'directory',
                                                                   owner: 'cndrcron',
                                                                   group: 'cndrcron',
                                                                   mode: '0755')
        end

        it do
          is_expected.to contain_file('/var/lock/condor-cron').with(ensure: 'directory',
                                                                    owner: 'cndrcron',
                                                                    group: 'cndrcron',
                                                                    mode: '0755')
        end

        it do
          is_expected.to contain_file('/var/log/condor-cron').with(ensure: 'directory',
                                                                   owner: 'cndrcron',
                                                                   group: 'cndrcron',
                                                                   mode: '0755')
        end
      end

      context 'osg::rsv::service' do
        it do
          is_expected.to contain_service('rsv').with(ensure: 'running',
                                                     enable: 'true',
                                                     hasstatus: 'true',
                                                     hasrestart: 'true')
        end

        it do
          is_expected.to contain_service('condor-cron').with(ensure: 'running',
                                                             enable: 'true',
                                                             hasstatus: 'true',
                                                             hasrestart: 'true',
                                                             before: 'Service[rsv]')
        end
      end

      context 'with manage_firewall => false' do
        let(:params) { { manage_firewall: false } }

        it { is_expected.not_to contain_firewall('100 allow RSV http access') }
      end
    end
  end
end
