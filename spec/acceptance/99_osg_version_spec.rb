require 'spec_helper_acceptance'
=begin
describe 'osg_version tests:' do
  it 'should not be empty' do
    expect(fact('osg_version', '--puppet')).should_not be_empty
  end
end
=end