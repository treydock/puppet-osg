require 'spec_helper_acceptance'

describe 'osg::ce class:' do
  node = only_host_with_role(hosts, 'ce')
  context "when default parameters" do

    it 'should run successfully' do
      pp =<<-EOS
        class { 'osg':
          auth_type => 'lcmaps_voms',
        }
        class { 'osg::cacerts::updater': }
        class { 'osg::ce':
          manage_firewall     => false,
          hostcert_source     => 'file:///tmp/hostcert.pem',
          hostkey_source      => 'file:///tmp/hostkey.pem',
          site_info_host_name => 'localhost',
          site_info_sponsor   => 'foo',
          site_info_contact   => 'Foo Bar',
          site_info_email     => 'foo@example.com',
          site_info_city      => 'Anywhere',
          site_info_country   => 'USA',
          site_info_longitude => '0',
          site_info_latitude  => '0',
          osg_gip_configs     => {
            'Subcluster TEST/name'           => { 'value' => 'TEST' },
            'Subcluster TEST/allowed_vos'    => { 'value' => 'foo' },
            'Subcluster TEST/ram_mb'         => { 'value' => 1024 },
            'Subcluster TEST/cores_per_node' => { 'value' => 1 },
          }
        }
      EOS

      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes => true)
    end

    it_behaves_like "osg::cacerts", node
    it_behaves_like "osg::cacerts::updater", node
  end

  context 'CE cleanup' do
    it 'deletes CE packages to pass non-CE tests' do
      # Cleanup the CE so osg-configure doesn't think CE is present for other tests
      on node, 'yum remove -y osg-ce osg-htcondor-ce osg-configure\* gratia\*'
      on node, 'rm -f /etc/osg/config.d/99-local-site-settings.ini'
    end
  end
end
