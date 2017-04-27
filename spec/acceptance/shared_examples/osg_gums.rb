shared_examples_for "osg::gums" do |node|
  case fact_on(node, 'operatingsystemrelease')
  when /^6/
    tomcat_service = 'tomcat6'
  when /^7/
    tomcat_service = 'tomcat'
  end

  describe package('osg-gums'), :node => node do
    it { should be_installed }
  end

  describe service(tomcat_service), :node => node do
    it { should be_enabled }
    it { should be_running }
  end

  describe port(8443), :node => node do
    it { should be_listening }
  end
end
