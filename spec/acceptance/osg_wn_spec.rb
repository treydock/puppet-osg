require 'spec_helper_acceptance'

describe 'osg::wn class:' do
  context 'when default parameters' do
    node = find_at_most_one_host_with_role(hosts, 'agent')

    it 'runs successfully' do
      pp = <<-EOS
        class { 'osg':
          auth_type => 'lcmaps_voms',
        }
        class { 'osg::wn': }
      EOS

      apply_manifest_on(node, pp, catch_failures: true)
      apply_manifest_on(node, pp, catch_changes: true)
    end
  end
end
