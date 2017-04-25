shared_examples_for "osg::client" do |node|
  describe package('osg-client'), :node => node do
    it { should be_installed }
  end
end
