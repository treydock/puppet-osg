# == Class: osg::params
#
# The osg configuration settings.
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

  $sudo_srm_commands = [
    '/bin/rm',
    '/bin/mkdir',
    '/bin/rmdir',
    '/bin/mv',
    '/bin/cp',
    '/bin/ls',
  ]
  $sudo_srm_runas = [
    'ALL',
    '!root',
  ]

  case $::osfamily {
    'RedHat': {
      case $::operatingsystemrelease {
        /6.\d/ : {
          $yum_priorities_package = 'yum-plugin-priorities'
          $tomcat_packages        = ['tomcat6']
          $crond_package_name     = 'cronie'
        }
        default : {
          fail("Unsupported operatingsystemrelease: ${::operatingsystemrelease}, module ${module_name} only support operatingsystemrelease >= 6.0")
        }
      }
    }

    default: {
      fail("Unsupported osfamily: ${::osfamily}, module ${module_name} only support osfamily RedHat")
    }
  }

}
