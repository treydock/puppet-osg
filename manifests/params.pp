# == Class: osg::params
#
# The osg configuration settings.
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if it
#   has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should not be used in preference to class parameters  as of
#   Puppet 2.6.)
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2013 Your name here, unless otherwise noted.
#
class osg::params {

  case $::osfamily {
    'RedHat': {
    }

    default: {
      fail("Unsupported osfamily: ${::osfamily}, module ${module_name} only support osfamily RedHat")
    }
  }

  $baseurl = $::osg_baseurl ? {
    undef   => 'UNSET',
    default => $::osg_baseurl,
  }
  $mirrorlist = $::osg_mirrorlist ? {
    undef   => "http://repo.grid.iu.edu/mirror/3.0/el${::os_maj_version}/osg-release/${::architecture}",
    default => $::osg_mirrorlist,
  }

}