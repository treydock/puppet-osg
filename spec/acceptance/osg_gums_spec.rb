require 'spec_helper_acceptance'

describe 'osg::gums class:' do
  context "when default parameters" do
    node = only_host_with_role(hosts, 'gums')

    it 'should run successfully' do
      pp =<<-EOS
        class { 'osg': }
        class { 'osg::gums':
          manage_firewall => false,
          httpcert_source => 'file:///tmp/httpcert.pem',
          httpkey_source  => 'file:///tmp/httpkey.pem',
        }
      EOS

      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes => true)
    end

    it_behaves_like "osg::repos", node
    it_behaves_like "osg::gums", node

  end
end
