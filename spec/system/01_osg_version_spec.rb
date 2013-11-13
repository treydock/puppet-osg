require 'spec_helper_system'

describe 'osg_version tests:' do
  context 'should be empty' do
    context shell 'facter --puppet osg_version' do
      its(:stdout) { should be_empty }
      its(:stderr) { should be_empty }
      its(:exit_code) { should be_zero }
    end
  end
end
