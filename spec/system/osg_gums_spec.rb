require 'spec_helper_system'

describe 'osg::gums class:' do

  context 'should run successfully' do
    pp = <<-EOS
      class { 'mysql::server': }
      class { 'osg': }
      class { 'osg::gums': }
    EOS

    context puppet_apply(pp) do
      # Removed as deprecation warnings produced from puppetlabs-mysql module
      #its(:stderr) { should be_empty }
      its(:exit_code) { should_not == 1 }
      its(:refresh) { should be_nil }
      # Removed as deprecation warnings produced from puppetlabs-mysql module
      #its(:stderr) { should be_empty }
      its(:exit_code) { should be_zero }
    end
  end
end
