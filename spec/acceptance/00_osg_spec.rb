require 'spec_helper_acceptance'

describe 'osg class:' do
  context "when default parameters" do
    node = find_at_most_one_host_with_role(hosts, 'agent')

    it 'should run successfully' do
      pp =<<-EOS
        class { 'osg': }
      EOS

      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes => true)
    end

    [
      'osg',
      'osg-empty',
    ].each do |repo|
      describe yumrepo(repo), :node => node do
        it { should exist }
        it { should be_enabled }
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
      describe yumrepo(repo), :node => node do
        it { should exist }
        it { should_not be_enabled }
      end
    end

  end
end
