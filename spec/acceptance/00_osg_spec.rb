require 'spec_helper_acceptance'

describe 'osg class:' do
  context 'when default parameters' do
    node = find_at_most_one_host_with_role(hosts, 'agent')

    it 'runs successfully' do
      pp = <<-EOS
      class { 'osg':
        auth_type => 'lcmaps_voms',
      }
      EOS

      apply_manifest_on(node, pp, catch_failures: true)
      apply_manifest_on(node, pp, catch_changes: true)
      on node, 'yum repolist'
    end

    [
      'osg',
      'osg-empty',
    ].each do |repo|
      describe yumrepo(repo), node: node do
        it { is_expected.to exist }
        it { is_expected.to be_enabled }
      end
    end

    [
      'osg-contrib',
      'osg-development',
      'osg-testing',
      'osg-upcoming',
      'osg-upcoming-development',
      'osg-upcoming-testing',
    ].each do |repo|
      describe yumrepo(repo), node: node do
        it { is_expected.to exist }
        it { is_expected.not_to be_enabled }
      end
    end
  end
end
