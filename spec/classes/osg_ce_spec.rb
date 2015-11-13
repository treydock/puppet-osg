require 'spec_helper'

describe 'osg::ce' do
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

      it { should create_class('osg::ce') }
      it { should contain_class('osg::params') }
      it { should contain_class('osg') }
      it { should contain_class('osg::cacerts') }

      it do
        should contain_class('osg::gridftp').with({
          :manage_hostcert  => 'true',
          :hostcert_source  => 'UNSET',
          :hostkey_source   => 'UNSET',
          :manage_firewall  => 'true',
          :standalone       => 'false'
        })
      end

      it { should contain_anchor('osg::ce::start').that_comes_before('Class[osg]') }
      it { should contain_class('osg').that_comes_before('Class[osg::cacerts]') }
      it { should contain_class('osg::cacerts').that_comes_before('Class[osg::ce::install]') }
      it { should contain_class('osg::ce::install').that_comes_before('Class[osg::gridftp]') }
      it { should contain_class('osg::gridftp').that_comes_before('Class[osg::ce::config]') }
      it { should contain_class('osg::ce::config').that_comes_before('Class[osg::ce::service]') }
      it { should contain_class('osg::ce::service').that_comes_before('Anchor[osg::ce::end]') }
      it { should contain_anchor('osg::ce::end') }

      it "should create Firewall[100 allow GRAM]" do
        should contain_firewall('100 allow GRAM').with({
          :ensure => 'present',
          :action => 'accept',
          :dport  => '2119',
          :proto  => 'tcp',
        })
      end

      context 'when manage_firewall => false' do
        let(:params) {{ :manage_firewall => false }}
        it { should_not contain_firewall('100 allow GRAM') }
      end

      context 'osg::ce::install' do
        it do
          should contain_package('empty-torque').with({
            :ensure => 'present',
            :before => 'Package[condor]',
          })
        end

        it do
          should contain_package('condor').with({
            :ensure => 'present',
            :before => 'Package[osg-ce]',
          })
        end

        it do
          should contain_package('osg-ce').with({
            :ensure => 'present',
            :name   => 'osg-ce-pbs',
          })
        end

        it { should_not contain_package('osg-configure-slurm') }
        it { should_not contain_package('gratia-probe-slurm') }

        context 'when use_slurm => true' do
          let(:params) {{ :use_slurm => true }}

          it do
            should contain_package('osg-configure-slurm').with({
              :ensure   => 'present',
              :require  => 'Package[osg-ce]',
            })
          end

          it do
            should contain_package('gratia-probe-slurm').with({
              :ensure   => 'present',
              :require  => 'Package[osg-ce]',
            })
          end
        end
      end

      context 'osg::ce::config' do
        it do
          should contain_file('/etc/grid-security/http').with({
            :ensure => 'directory',
            :owner  => 'tomcat',
            :group  => 'tomcat',
            :mode   => '0755',
          })
        end

        it do
          should contain_file('/etc/grid-security/http/httpcert.pem').with({
            :ensure   => 'file',
            :owner    => 'tomcat',
            :group    => 'tomcat',
            :mode     => '0444',
            :source   => nil,
            :require  => 'File[/etc/grid-security/http]',
          })
        end

        it do
          should contain_file('/etc/grid-security/http/httpkey.pem').with({
            :ensure   => 'file',
            :owner    => 'tomcat',
            :group    => 'tomcat',
            :mode     => '0400',
            :source   => nil,
            :require  => 'File[/etc/grid-security/http]',
          })
        end

        if Gem::Version.new(Gem.loaded_specs['puppet'].version.to_s) >= Gem::Version.new('3.2.0')
          it { should contain_file('/etc/grid-security/http/httpcert.pem').with_show_diff('false') }
          it { should contain_file('/etc/grid-security/http/httpkey.pem').with_show_diff('false') }
        else
          it { should contain_file('/etc/grid-security/http/httpcert.pem').without_show_diff }
          it { should contain_file('/etc/grid-security/http/httpkey.pem').without_show_diff }
        end

        {
          'Gateway/gram_gateway_enabled' => 'true',
          'Gateway/htcondor_gateway_enabled' => 'true',
          'Site Information/group' => 'OSG',
          'Site Information/host_name' => facts[:fqdn],
          'Site Information/resource' => 'UNAVAILABLE',
          'Site Information/resource_group' => 'UNAVAILABLE',
          'Site Information/sponsor' => 'UNAVAILABLE',
          'Site Information/site_policy' => 'UNAVAILABLE',
          'Site Information/contact' => 'UNAVAILABLE',
          'Site Information/email' => 'UNAVAILABLE',
          'Site Information/city' => 'UNAVAILABLE',
          'Site Information/country' => 'UNAVAILABLE',
          'Site Information/longitude' => 'UNAVAILABLE',
          'Site Information/latitude' => 'UNAVAILABLE',
        }.each_pair do |k,v|
          it { should contain_osg_local_site_settings(k).with_value(v) }
          it { should contain_osg_local_site_settings(k).that_notifies('Exec[osg-configure]') }
        end
      end

      context 'osg::ce::service' do
        it do
          should contain_service('globus-gatekeeper').with({
            :ensure     => 'running',
            :enable     => 'true',
            :hasstatus  => 'true',
            :hasrestart => 'true',
            :subscribe  => [
              'File[/etc/grid-security/hostcert.pem]',
              'File[/etc/grid-security/hostkey.pem]',
            ],
            :before     => 'Service[osg-info-services]', 
          })
        end

        it do
          should contain_service('osg-info-services').with({
            :ensure     => 'running',
            :enable     => 'true',
            :hasstatus  => 'true',
            :hasrestart => 'true',
            :subscribe  => [
              'File[/etc/grid-security/http/httpcert.pem]',
              'File[/etc/grid-security/http/httpkey.pem]',
            ],
            :before     => ['Service[gratia-probes-cron]'],
          })
        end

        it do
          should contain_service('gratia-probes-cron').with({
            :ensure     => 'running',
            :enable     => 'true',
            :hasstatus  => 'true',
            :hasrestart => 'true',
            :before     => ['Service[osg-cleanup-cron]'],
          })
        end

        it do
          should contain_service('osg-cleanup-cron').with({
            :ensure     => 'running',
            :enable     => 'true',
            :hasstatus  => 'true',
            :hasrestart => 'true',
            :before     => nil, 
          })
        end
      end

      # Test validate_bool parameters
      [
        'use_slurm',
        'manage_firewall',
      ].each do |param|
        context "with #{param} => 'foo'" do
          let(:params) {{ param.to_sym => 'foo' }}
          it { expect { should create_class('osg::ce') }.to raise_error(Puppet::Error, /is not a boolean/) }
        end
      end

    end
  end
end
