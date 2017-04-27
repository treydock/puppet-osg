# Private class: See README.md.
class osg::gums::install {

  package { 'osg-gums':
    ensure => installed,
    notify => Exec['/var/lib/trustmanager-tomcat/configure.sh'],
  }

  exec { '/var/lib/trustmanager-tomcat/configure.sh':
    refreshonly => true,
    logoutput   => true,
  }

}
