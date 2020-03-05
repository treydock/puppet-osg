shared_examples_for 'osg::client' do |node|
  describe package('condor'), node: node do
    it { is_expected.to be_installed }
  end
  describe package('htcondor-ce'), node: node do
    it { is_expected.to be_installed }
  end
end
