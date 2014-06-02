require 'spec_helper_acceptance'

describe 'osg::wn class:' do
  context "when default parameters" do
    node = only_host_with_role(hosts, 'wn')

    it 'should run successfully' do
      pp =<<-EOS
        file { '/opt/grid-certificates': ensure => 'directory' }->
        class { 'osg': }
        class { 'osg::wn': }
      EOS

      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes => true)
    end

    it_behaves_like "osg::repos", node

  end
end
