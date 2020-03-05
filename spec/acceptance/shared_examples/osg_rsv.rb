shared_examples_for 'osg::rsv' do |node|
  describe package('rsv'), node: node do
    it { is_expected.to be_installed }
  end

  describe service('rsv'), node: node do
    it { is_expected.to be_enabled }
  end
end
