require 'spec_helper_acceptance'

describe 'osg::client class:' do
  context "when default parameters" do
    node = only_host_with_role(hosts, 'client')

    it 'should run successfully' do
      pp =<<-EOS
        class { 'osg': }
        class { 'osg::client':
          manage_firewall => false,
        }
      EOS

      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes => true)
    end

    it_behaves_like "osg::client", node

  end
end
