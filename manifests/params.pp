# Private class: See README.md.
class osg::params {

  $utils_packages = [
    'globus-proxy-utils',
    'osg-pki-tools',
  ]

  case $::osfamily {
    'RedHat': {
      case $::operatingsystemmajrelease {
        '7': {
          $yum_priorities_package = 'yum-plugin-priorities'
        }
        '6': {
          $yum_priorities_package = 'yum-plugin-priorities'
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
