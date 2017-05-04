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
        '7': {
          $osg_release            = '3.3'
          $yum_priorities_package = 'yum-plugin-priorities'
          $tomcat_package         = 'tomcat'
          $tomcat_base_dir        = '/usr/share/tomcat'
          $tomcat_conf_dir        = '/etc/tomcat'
          $tomcat_log_dir         = '/var/log/tomcat'
          $tomcat_service         = 'tomcat'
          $crond_package_name     = 'cronie'
        }
        '6': {
          $osg_release            = '3.3'
          $yum_priorities_package = 'yum-plugin-priorities'
          $tomcat_package         = 'tomcat6'
          $tomcat_base_dir        = '/usr/share/tomcat6'
          $tomcat_conf_dir        = '/etc/tomcat6'
          $tomcat_log_dir         = '/var/log/tomcat6'
          $tomcat_service         = 'tomcat6'
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
