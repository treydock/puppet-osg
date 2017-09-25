shared_examples_for "osg::cacerts::updater" do |node|
  describe package('osg-ca-certs-updater'), :node => node do
    it { should be_installed }
  end

  describe package('fetch-crl'), :node => node do
    it { should be_installed }
  end

  describe service('osg-ca-certs-updater-cron'), :node => node do
    it { should be_enabled }
    it { should be_running }
  end

  describe service('fetch-crl-boot'), :node => node do
    it { should_not be_enabled }
    it { should_not be_running }
  end

  describe service('fetch-crl-cron'), :node => node do
    it { should be_enabled }
    it { should be_running }
  end
end
