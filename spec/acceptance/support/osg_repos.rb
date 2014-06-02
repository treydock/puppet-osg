shared_examples_for "osg::repos" do |node|
  describe yumrepo('osg'), :node => node do
    it { should exist }
    it { should be_enabled }
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
