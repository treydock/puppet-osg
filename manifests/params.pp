# Private class: See README.md.
class osg::params {

  if $::operatingsystemmajrelease {
    $os_releasever = $::operatingsystemmajrelease
  } elsif $::os_maj_version {
    $os_releasever = $::os_maj_version
  } else {
    $os_releasever = inline_template("<%= \"${::operatingsystemrelease}\".split('.').first %>")
  }

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
      case $os_releasever {
        '6': {
          $yum_priorities_package = 'yum-plugin-priorities'
          $tomcat_packages        = ['tomcat6']
          $crond_package_name     = 'cronie'
        }
        default: {
          fail("Unsupported operating system: EL${os_releasever}, module ${module_name} only support EL6")
        }
      }
    }

    default: {
      fail("Unsupported osfamily: ${::osfamily}, module ${module_name} only support osfamily RedHat")
    }
  }

}
