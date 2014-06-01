require 'spec_helper'

describe 'osg' do
  include_context :defaults

  let :facts do
    default_facts.merge({

    })
  end

  it { should contain_class('osg::params') }
  it { should contain_class('osg::repo') }

  it do
    should contain_exec('osg-configure').with({
      :path         => ['/usr/bin','/bin','/usr/sbin','/sbin'],
      :command      => '/usr/sbin/osg-configure -c',
      :onlyif       => ['test -f /usr/sbin/osg-configure', '/usr/sbin/osg-configure -v'],
      :refreshonly  => 'true',
    })
  end
end
