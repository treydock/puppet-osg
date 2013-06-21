require 'puppetlabs_spec_helper/module_spec_helper'

def default_facts
  {
    :kernel                 => 'Linux',
    :osfamily               => 'RedHat',
    :operatingsystem        => 'CentOS',
    :operatingsystemrelease => '6.4',
    :architecture           => 'x86_64',
    :os_maj_version         => '6',
  }
end
