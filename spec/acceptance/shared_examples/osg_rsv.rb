shared_examples_for "osg::rsv" do |node|
  describe package('rsv'), :node => node do
    it { should be_installed }
  end

  describe service('rsv'), :node => node do
    it { should be_enabled }
  end
end
