require 'spec_helper_system'

describe 'osg class:' do
  context 'no params:' do
    let(:pp) do
      pp = <<-EOS
      class { 'osg': }
      EOS
    end

    it 'should run with no errors' do
      puppet_apply(pp) do |r|
        r.stderr.should be_empty
        r.exit_code.should_not eq(1)
      end
    end

    it 'should be idempotent' do
      puppet_apply(pp) do |r|
        r.stderr.should be_empty
        r.exit_code.should be_zero
      end
    end
  end
end