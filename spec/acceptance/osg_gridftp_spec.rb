require 'spec_helper_acceptance'

describe 'osg::gridftp class:' do
  node = find_at_most_one_host_with_role(hosts, 'agent')
  context 'when default parameters' do
    it 'runs successfully' do
      pp = <<-EOS
        class { 'osg':
          auth_type           => 'lcmaps_voms',
          site_info_host_name => 'localhost',
          site_info_resource  => 'TEST',
          site_info_sponsor   => 'foo',
          site_info_contact   => 'Foo Bar',
          site_info_email     => 'foo@example.com',
          site_info_city      => 'Anywhere',
          site_info_country   => 'USA',
          site_info_longitude => '0',
          site_info_latitude  => '0',
        }
        class { 'osg::gridftp':
          manage_firewall => false,
          hostcert_source => 'file:///tmp/hostcert.pem',
          hostkey_source  => 'file:///tmp/hostkey.pem',
        }
      EOS

      apply_manifest_on(node, pp, catch_failures: true)
      apply_manifest_on(node, pp, catch_changes: true)
    end
  end

  context 'GridFTP cleanup' do
    it 'deletes GridFTP packages to pass non-GridFTP tests' do
      # Cleanup the GridFTP so osg-configure works later
      on node, 'yum remove -y osg-gridftp osg-configure\*'
      on node, 'rm -f /etc/osg/config.d/99-local-site-settings.ini'
    end
  end
end
