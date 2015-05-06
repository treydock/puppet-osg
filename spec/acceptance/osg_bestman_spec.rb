require 'spec_helper_acceptance'

describe 'osg::bestman class:' do
  context "when default parameters" do
    node = only_host_with_role(hosts, 'bestman')

    it 'should run successfully' do
      pp =<<-EOS
        # Prevent sudo module from breaking Vagrant
        class { 'sudo': purge => false, config_file_replace => false }
        class { 'osg': }
        class { 'osg::bestman':
          bestmancert_source => 'file:///tmp/bestmancert.pem',
          bestmankey_source  => 'file:///tmp/bestmankey.pem',
        }
      EOS

      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes => true)
    end

    it_behaves_like "osg::repos", node
    it_behaves_like "osg::bestman", node

  end
end
