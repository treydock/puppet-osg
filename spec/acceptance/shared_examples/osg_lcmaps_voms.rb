shared_examples_for "osg::osg_lcmaps_voms" do |node|
  describe package('lcmaps'), :node => node do
    it { should be_installed }
  end
  describe package('vo-client-lcmaps-voms'), :node => node do
    it { should be_installed }
  end
  describe package('osg-configure-misc'), :node => node do
    it { should be_installed }
  end

  describe file('/etc/grid-security/voms-mapfile'), :node => node do
    it { should be_file }
  end
  describe file('/etc/grid-security/grid-mapfile'), :node => node do
    it { should be_file }
  end
  describe file('/etc/grid-security/ban-voms-mapfile'), :node => node do
    it { should be_file }
  end
  describe file('/etc/grid-security/ban-mapfile'), :node => node do
    it { should be_file }
  end
end
