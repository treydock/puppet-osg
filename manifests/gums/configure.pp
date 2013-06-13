# == Class: osg::gums::configure
#
# This is intended to replace the need to run '/var/lib/trustmanager-tomcat/configure.sh'.
#
# === Parameters
#
# Document parameters here.
#
# [*port*]
#   Port used by the GUMS service.
#   Default: 8443
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2013 Trey Dockendorf
#
class osg::gums::configure (
  $port   = $osg::gums::port
) inherits osg::gums {

  Class['osg::gums'] -> Class['osg::gums::configure']

  file { '/etc/tomcat6/server.xml':
    ensure  => present,
    content => template('osg/gums/server.xml.erb'),
    owner   => 'tomcat',
    group   => 'root',
    mode    => '0664',
    notify  => Service['tomcat6'],
    require => Package['osg-gums'],
  }

  file { '/etc/tomcat6/log4j-trustmanager.properties':
    ensure  => present,
    content => template('osg/gums/log4j-trustmanager.properties.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Service['tomcat6'],
    require => Package['osg-gums'],
  }

  file { '/usr/share/tomcat6/lib/bcprov.jar':
    ensure  => 'link',
    target  => '/usr/share/java/bcprov.jar',
    require => Package['osg-gums'],
  }

  file { '/usr/share/tomcat6/lib/trustmanager.jar':
    ensure  => 'link',
    target  => '/usr/share/java/trustmanager.jar',
    require => Package['osg-gums'],
  }

  file { '/usr/share/tomcat6/lib/trustmanager-tomcat.jar':
    ensure  => 'link',
    target  => '/usr/share/java/trustmanager-tomcat.jar',
    require => Package['osg-gums'],
  }

  file { '/usr/share/tomcat6/lib/commons-logging.jar':
    ensure  => 'link',
    target  => '/usr/share/java/commons-logging.jar',
    require => Package['osg-gums'],
  }
}
