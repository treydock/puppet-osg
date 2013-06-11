# == Class: osg::params
#
# The osg configuration settings.
#
# === Variables
#
# [*osg_baseurl*]
#   Sets the baseurl used by the OSG yum repo.
#
# [*osg_mirrorlist*]
#   Sets the mirrorlist used by the OSG yum repo.
#   The mirrorlist value can be removed by assigning the value false or undef.
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2013 Trey Dockendorf
#
class osg::params {

  case $::osfamily {
    'RedHat': {
      case $::operatingsystemrelease {
        /6.\d/ : { }
        default : {
          fail("Unsupported operatingsystemrelease: ${::operatingsystemrelease}, module ${module_name} only support operatingsystemrelease >= 6.0")
        }
      }
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