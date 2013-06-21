require 'spec_helper_system'

describe 'osg_version tests:' do
  context puppet_agent do
    its(:stderr) { should be_empty }
    its(:exit_code) { should_not == 1 }
  end

  context 'should be empty' do
    context shell 'facter --puppet osg_version' do
      its(:stdout) { should be_empty }
      its(:stderr) { should be_empty }
      its(:exit_code) { should be_zero }
    end
  end
end
