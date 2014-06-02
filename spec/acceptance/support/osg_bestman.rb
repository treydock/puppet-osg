shared_examples_for "osg::bestman" do |node|
  describe package('osg-se-bestman'), :node => node do
    it { should be_installed }
  end

  describe service('bestman2'), :node => node do
    it { should be_enabled }
    it { should be_running }
  end
end
