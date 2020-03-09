require 'spec_helper'

describe 'osg::configure' do
  on_supported_os(supported_os: [
                    {
                      'operatingsystem' => 'CentOS',
                      'operatingsystemrelease' => ['7'],
                    },
                  ]).each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it do
        is_expected.to contain_exec('osg-configure').with(path: ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
                                                          command: '/usr/sbin/osg-configure -c',
                                                          onlyif: ['test -f /usr/sbin/osg-configure'],
                                                          refreshonly: 'true')
      end
    end
  end
end
