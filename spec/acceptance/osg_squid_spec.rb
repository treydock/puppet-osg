require 'spec_helper_acceptance'

describe 'osg::squid class:' do
  context "when default parameters" do
    node = only_host_with_role(hosts, 'squid')

    it 'should run successfully' do
      pp =<<-EOS
        class { 'osg': }
        class { 'osg::squid':
          manage_firewall => false,
        }
      EOS

      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes => true)
    end

  end
end
