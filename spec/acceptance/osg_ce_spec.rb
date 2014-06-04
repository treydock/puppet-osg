require 'spec_helper_acceptance'

describe 'osg::ce class:' do
  context "when default parameters" do
    node = only_host_with_role(hosts, 'ce')

    it 'should run successfully' do
      pp =<<-EOS
        class { 'osg': }
        class { 'osg::ce':
          hostcert_source => 'file:///tmp/hostcert.pem',
          hostkey_source  => 'file:///tmp/hostkey.pem',
          httpcert_source => 'file:///tmp/httpcert.pem',
          httpkey_source  => 'file:///tmp/httpkey.pem',
        }
        class { 'osg::rsv':
          rsvcert_source => 'file:///tmp/rsvcert.pem',
          rsvkey_source  => 'file:///tmp/rsvkey.pem',
        }
      EOS

      pending("fails as gratia probes not yet enabled") do
        apply_manifest_on(node, pp, :catch_failures => true)
        apply_manifest_on(node, pp, :catch_changes => true)
      end
    end

    it_behaves_like "osg::repos", node
    it_behaves_like "osg::rsv", node

  end
end
