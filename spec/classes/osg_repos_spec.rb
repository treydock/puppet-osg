require 'spec_helper'

describe 'osg::repos' do
  on_supported_os(supported_os: [
                    {
                      'operatingsystem' => 'CentOS',
                      'operatingsystemrelease' => ['7'],
                    },
                  ]).each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      osg_release = '3.5'

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to create_class('osg::repos') }
      it { is_expected.to contain_class('osg') }

      it { is_expected.to contain_package('yum-plugin-priorities').with_ensure('installed') }

      it do
        is_expected.to contain_yumrepo('osg-empty').only_with(name: 'osg-empty',
                                                              baseurl: 'absent',
                                                              mirrorlist: "https://repo.opensciencegrid.org/mirror/osg/#{osg_release}/el#{facts[:operatingsystemmajrelease]}/empty/x86_64",
                                                              descr: "OSG Software for Enterprise Linux #{facts[:operatingsystemmajrelease]} - Empty Packages - x86_64",
                                                              enabled: '1',
                                                              failovermethod: 'priority',
                                                              gpgcheck: '1',
                                                              gpgkey: 'https://repo.opensciencegrid.org/osg/RPM-GPG-KEY-OSG',
                                                              priority: '98',
                                                              includepkgs: 'empty-ca-certs empty-slurm empty-torque')
      end

      [
        { name: 'osg', path: 'release', desc: '', enabled: '1' },
        { name: 'osg-contrib', path: 'contrib', desc: ' - Contributed', enabled: '0' },
        { name: 'osg-development', path: 'development', desc: ' - Development', enabled: '0' },
        { name: 'osg-testing', path: 'testing', desc: ' - Testing', enabled: '0' },
      ].each do |h|
        it do
          is_expected.to contain_yumrepo(h[:name]).only_with(name: h[:name],
                                                             baseurl: 'absent',
                                                             mirrorlist: "https://repo.opensciencegrid.org/mirror/osg/#{osg_release}/el#{facts[:operatingsystemmajrelease]}/#{h[:path]}/x86_64",
                                                             descr: "OSG Software for Enterprise Linux #{facts[:operatingsystemmajrelease]}#{h[:desc]} - x86_64",
                                                             enabled: h[:enabled],
                                                             failovermethod: 'priority',
                                                             gpgcheck: '1',
                                                             gpgkey: 'https://repo.opensciencegrid.org/osg/RPM-GPG-KEY-OSG',
                                                             priority: '98')
        end
      end

      [
        { name: 'osg-upcoming', path: 'release', desc: 'Upcoming', enabled: '1' },
        { name: 'osg-upcoming-development', path: 'development', desc: 'Upcoming Development', enabled: '0' },
        { name: 'osg-upcoming-testing', path: 'testing', desc: 'Upcoming Testing', enabled: '0' },
      ].each do |h|
        it do
          is_expected.to contain_yumrepo(h[:name]).only_with(name: h[:name],
                                                             baseurl: 'absent',
                                                             mirrorlist: "https://repo.opensciencegrid.org/mirror/osg/upcoming/el#{facts[:operatingsystemmajrelease]}/#{h[:path]}/x86_64",
                                                             descr: "OSG Software for Enterprise Linux #{facts[:operatingsystemmajrelease]} - #{h[:desc]} - x86_64",
                                                             enabled: h[:enabled],
                                                             failovermethod: 'priority',
                                                             gpgcheck: '1',
                                                             gpgkey: 'https://repo.opensciencegrid.org/osg/RPM-GPG-KEY-OSG',
                                                             priority: '98')
        end
      end

      context 'when repo_use_mirrors => false' do
        let(:pre_condition) { "class { 'osg': repo_use_mirrors => false }" }

        it do
          is_expected.to contain_yumrepo('osg-empty').only_with(name: 'osg-empty',
                                                                baseurl: "https://repo.opensciencegrid.org/osg/#{osg_release}/el#{facts[:operatingsystemmajrelease]}/empty/x86_64",
                                                                mirrorlist: 'absent',
                                                                descr: "OSG Software for Enterprise Linux #{facts[:operatingsystemmajrelease]} - Empty Packages - x86_64",
                                                                enabled: '1',
                                                                failovermethod: 'priority',
                                                                gpgcheck: '1',
                                                                gpgkey: 'https://repo.opensciencegrid.org/osg/RPM-GPG-KEY-OSG',
                                                                priority: '98',
                                                                includepkgs: 'empty-ca-certs empty-slurm empty-torque')
        end

        [
          { name: 'osg', path: 'release', desc: '', enabled: '1' },
          { name: 'osg-contrib', path: 'contrib', desc: ' - Contributed', enabled: '0' },
          { name: 'osg-development', path: 'development', desc: ' - Development', enabled: '0' },
          { name: 'osg-testing', path: 'testing', desc: ' - Testing', enabled: '0' },
        ].each do |h|
          it do
            is_expected.to contain_yumrepo(h[:name]).only_with(name: h[:name],
                                                               baseurl: "https://repo.opensciencegrid.org/osg/#{osg_release}/el#{facts[:operatingsystemmajrelease]}/#{h[:path]}/x86_64",
                                                               mirrorlist: 'absent',
                                                               descr: "OSG Software for Enterprise Linux #{facts[:operatingsystemmajrelease]}#{h[:desc]} - x86_64",
                                                               enabled: h[:enabled],
                                                               failovermethod: 'priority',
                                                               gpgcheck: '1',
                                                               gpgkey: 'https://repo.opensciencegrid.org/osg/RPM-GPG-KEY-OSG',
                                                               priority: '98')
          end
        end

        [
          { name: 'osg-upcoming', path: 'release', desc: 'Upcoming', enabled: '1' },
          { name: 'osg-upcoming-development', path: 'development', desc: 'Upcoming Development', enabled: '0' },
          { name: 'osg-upcoming-testing', path: 'testing', desc: 'Upcoming Testing', enabled: '0' },
        ].each do |h|
          it do
            is_expected.to contain_yumrepo(h[:name]).only_with(name: h[:name],
                                                               baseurl: "https://repo.opensciencegrid.org/osg/upcoming/el#{facts[:operatingsystemmajrelease]}/#{h[:path]}/x86_64",
                                                               mirrorlist: 'absent',
                                                               descr: "OSG Software for Enterprise Linux #{facts[:operatingsystemmajrelease]} - #{h[:desc]} - x86_64",
                                                               enabled: h[:enabled],
                                                               failovermethod: 'priority',
                                                               gpgcheck: '1',
                                                               gpgkey: 'https://repo.opensciencegrid.org/osg/RPM-GPG-KEY-OSG',
                                                               priority: '98')
          end
        end

        context 'when repo_urlbit => "https://foo.example.com"' do
          let(:pre_condition) { "class { 'osg': repo_use_mirrors => false, repo_baseurl_bit => 'https://foo.example.com' }" }

          it do
            is_expected.to contain_yumrepo('osg-empty').only_with(name: 'osg-empty',
                                                                  baseurl: "https://foo.example.com/osg/#{osg_release}/el#{facts[:operatingsystemmajrelease]}/empty/x86_64",
                                                                  mirrorlist: 'absent',
                                                                  descr: "OSG Software for Enterprise Linux #{facts[:operatingsystemmajrelease]} - Empty Packages - x86_64",
                                                                  enabled: '1',
                                                                  failovermethod: 'priority',
                                                                  gpgcheck: '1',
                                                                  gpgkey: 'https://repo.opensciencegrid.org/osg/RPM-GPG-KEY-OSG',
                                                                  priority: '98',
                                                                  includepkgs: 'empty-ca-certs empty-slurm empty-torque')
          end

          [
            { name: 'osg', path: 'release', desc: '', enabled: '1' },
            { name: 'osg-contrib', path: 'contrib', desc: ' - Contributed', enabled: '0' },
            { name: 'osg-development', path: 'development', desc: ' - Development', enabled: '0' },
            { name: 'osg-testing', path: 'testing', desc: ' - Testing', enabled: '0' },
          ].each do |h|
            it do
              is_expected.to contain_yumrepo(h[:name]).only_with(name: h[:name],
                                                                 baseurl: "https://foo.example.com/osg/#{osg_release}/el#{facts[:operatingsystemmajrelease]}/#{h[:path]}/x86_64",
                                                                 mirrorlist: 'absent',
                                                                 descr: "OSG Software for Enterprise Linux #{facts[:operatingsystemmajrelease]}#{h[:desc]} - x86_64",
                                                                 enabled: h[:enabled],
                                                                 failovermethod: 'priority',
                                                                 gpgcheck: '1',
                                                                 gpgkey: 'https://repo.opensciencegrid.org/osg/RPM-GPG-KEY-OSG',
                                                                 priority: '98')
            end
          end

          [
            { name: 'osg-upcoming', path: 'release', desc: 'Upcoming', enabled: '1' },
            { name: 'osg-upcoming-development', path: 'development', desc: 'Upcoming Development', enabled: '0' },
            { name: 'osg-upcoming-testing', path: 'testing', desc: 'Upcoming Testing', enabled: '0' },
          ].each do |h|
            it do
              is_expected.to contain_yumrepo(h[:name]).only_with(name: h[:name],
                                                                 baseurl: "https://foo.example.com/osg/upcoming/el#{facts[:operatingsystemmajrelease]}/#{h[:path]}/x86_64",
                                                                 mirrorlist: 'absent',
                                                                 descr: "OSG Software for Enterprise Linux #{facts[:operatingsystemmajrelease]} - #{h[:desc]} - x86_64",
                                                                 enabled: h[:enabled],
                                                                 failovermethod: 'priority',
                                                                 gpgcheck: '1',
                                                                 gpgkey: 'https://repo.opensciencegrid.org/osg/RPM-GPG-KEY-OSG',
                                                                 priority: '98')
            end
          end
        end
      end

      context 'when enable_osg_contrib => true' do
        let(:pre_condition) { "class { 'osg': enable_osg_contrib => true }" }

        it { is_expected.to contain_yumrepo('osg-contrib').with_enabled('1') }
      end
    end
  end
end
