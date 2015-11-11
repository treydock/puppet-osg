# Private class: See README.md.
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
      case $::operatingsystemmajrelease {
        /6|7/: {
          $yum_priorities_package = 'yum-plugin-priorities'
          $tomcat_packages        = ['tomcat6']
          $crond_package_name     = 'cronie'
        }
        default: {
          fail("Unsupported operating system: EL${::operatingsystemmajrelease}, module ${module_name} only support EL6 and EL7")
        }
      }
    }

    default: {
      fail("Unsupported osfamily: ${::osfamily}, module ${module_name} only support osfamily RedHat")
    }
  }

}
