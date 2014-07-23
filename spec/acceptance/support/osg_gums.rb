shared_examples_for "osg::gums" do |node|
  describe package('osg-gums'), :node => node do
    it { should be_installed }
  end

  describe service('tomcat6'), :node => node do
    it { should be_enabled }
    it { should be_running }
  end

  describe port(8443) do
    it { should be_listening }
  end
end
