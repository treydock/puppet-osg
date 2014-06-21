require 'spec_helper_acceptance'

describe 'osg::cvmfs class:' do
  context "when default parameters" do
    node = only_host_with_role(hosts, 'cvmfs')

    it 'should run successfully' do
      pp =<<-EOS
        class { 'osg': }
        class { 'osg::cvmfs': http_proxies => ['DIRECT'] }
      EOS

      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes => true)
    end

    it_behaves_like "osg::repos", node

  end
end
