def verify_exact_contents(subject, title, expected_lines)
  content = subject.resource('file', title).send(:parameters)[:content]
  expect(content.split("\n").reject { |line| line =~ %r{(^$|^#)} }).to eq(expected_lines)
end

RSpec.configure do |config|
  config.default_facter_version = '3.11.9'
end
