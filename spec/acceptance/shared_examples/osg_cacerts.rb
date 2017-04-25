shared_examples_for "osg::cacerts" do |node|
  describe package('osg-ca-certs'), :node => node do
    it { should be_installed }
  end

  describe file('/etc/grid-security'), :node => node do
    it { should be_directory }
  end

  describe file('/etc/grid-security/certificates'), :node => node do
    it { should be_directory }
  end
end
