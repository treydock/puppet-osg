require 'spec_helper_acceptance'
=begin
describe 'osg_version tests:' do
  it 'should be empty' do
    expect(fact('osg_version', '--puppet')).should be_empty
  end
end
=end