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
      let(:facts) { facts }

      let(:params) {{ }}

      it { should compile.with_all_deps }
      it { should create_class('osg::ce') }
      it { should contain_class('osg::params') }
      it { should contain_class('osg') }
      it { should contain_class('osg::cacerts') }

      it do
        should contain_class('osg::gridftp').with({
          :manage_hostcert  => 'true',
          :hostcert_source  => nil,
          :hostkey_source   => nil,
          :manage_firewall  => 'true',
          :standalone       => 'false'
        })
      end

      it { should contain_anchor('osg::ce::start').that_comes_before('Class[osg]') }
      it { should contain_class('osg').that_comes_before('Class[osg::cacerts]') }
      it { should contain_class('osg::cacerts').that_comes_before('Class[osg::ce::users]') }
      it { should contain_class('osg::ce::users').that_comes_before('Class[osg::ce::install]') }
      it { should contain_class('osg::ce::install').that_comes_before('Class[osg::gridftp]') }
      it { should contain_class('osg::gridftp').that_comes_before('Class[osg::ce::config]') }
      it { should contain_class('osg::ce::config').that_comes_before('Class[osg::ce::service]') }
      it { should contain_class('osg::ce::service').that_comes_before('Anchor[osg::ce::end]') }
      it { should contain_anchor('osg::ce::end') }

      it "should create Firewall[100 allow HTCondorCE]" do
        should contain_firewall('100 allow HTCondorCE').with({
          :ensure => 'present',
          :action => 'accept',
          :dport  => '9619',
          :proto  => 'tcp',
        })
      end

      it "should create Firewall[100 allow HTCondorCE shared_port]" do
        should contain_firewall('100 allow HTCondorCE shared_port').with({
          :ensure => 'present',
          :action => 'accept',
          :dport  => '9620',
          :proto  => 'tcp',
        })
      end

      context 'when manage_firewall => false' do
        let(:params) {{ :manage_firewall => false }}
        it { should_not contain_firewall('100 allow GRAM') }
      end

      context 'osg::ce::install' do
        it do
          should_not contain_package('empty-torque')
        end

        it do
          should contain_package('osg-ce-pbs').with({
            :ensure => 'present',
          })
        end

        context 'when batch_system => slurm' do
          let(:params) {{ :batch_system => 'slurm' }}

          it do
            should contain_package('empty-slurm').with({
              :ensure => 'present',
              :before => 'Package[osg-ce-slurm]',
            })
          end

          it do
            should contain_package('osg-ce-slurm').with({
              :ensure => 'present',
            })
          end
        end
      end

      context 'osg::ce::config' do
        {
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
          'Network/port_range' => '40000,41999',
        }.each_pair do |k,v|
          it { should contain_osg_local_site_settings(k).with_value(v) }
          it { should contain_osg_local_site_settings(k).that_notifies('Exec[osg-configure]') }
        end

        context 'when osg_local_site_settings defined' do
          let(:params) do
            {
              :osg_local_site_settings => {
                'SLURM/enabled' => {'value' => true},
                'Gratia/enabled' => {'value' => true},
              }
            }
          end

          it { should contain_osg_local_site_settings('SLURM/enabled').with_value('true') }
          it { should contain_osg_local_site_settings('SLURM/enabled').that_notifies('Exec[osg-configure]') }
          it { should contain_osg_local_site_settings('Gratia/enabled').with_value('true') }
          it { should contain_osg_local_site_settings('Gratia/enabled').that_notifies('Exec[osg-configure]') }
        end

        context 'when osg_gip_configs defined' do
          let(:params) do
            {
              :osg_gip_configs => {
                'GIP/batch' => {'value' => 'slurm'},
                'GIP/advertise_gums' => {'value' => false},
              }
            }
          end

          it { should contain_osg_gip_config('GIP/batch').with_value('slurm') }
          it { should contain_osg_gip_config('GIP/batch').that_notifies('Exec[osg-configure]') }
          it { should contain_osg_gip_config('GIP/advertise_gums').with_value('false') }
          it { should contain_osg_gip_config('GIP/advertise_gums').that_notifies('Exec[osg-configure]') }
        end
      end

      context 'osg::ce::service' do
        it do
          should contain_service('condor-ce').with({
            :ensure     => 'running',
            :enable     => 'true',
            :hasstatus  => 'true',
            :hasrestart => 'true',
            :subscribe  => [
              'File[/etc/grid-security/hostcert.pem]',
              'File[/etc/grid-security/hostkey.pem]',
            ],
          })
        end

        it do
          should contain_service('gratia-probes-cron').with({
            :ensure     => 'running',
            :enable     => 'true',
            :hasstatus  => 'true',
            :hasrestart => 'true',
          })
        end
      end

    end
  end
end
