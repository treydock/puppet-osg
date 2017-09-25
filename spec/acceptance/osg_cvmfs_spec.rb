require 'spec_helper_acceptance'

describe 'osg::cvmfs class:' do
  before { skip("autofs fails") }
  context "when default parameters" do
    node = only_host_with_role(hosts, 'wn')

    it 'should run successfully' do
      pp =<<-EOS
        class { 'osg': }
        class { 'osg::cvmfs': http_proxies => ['DIRECT'] }
      EOS

      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes => true)
    end

  end
end
