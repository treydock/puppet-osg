require 'spec_helper'

describe 'osg::configure' do
  include_context :defaults

  let(:facts) { default_facts }

  it do
    should contain_exec('osg-configure').with({
      :path         => ['/usr/bin','/bin','/usr/sbin','/sbin'],
      :command      => '/usr/sbin/osg-configure -c',
      :onlyif       => ['test -f /usr/sbin/osg-configure', '/usr/sbin/osg-configure -v'],
      :refreshonly  => 'true',
    })
  end
end
