# == Class: osg::tomcat
#
# Basic configuration for Tomcat.
# Intended for use with GUMS.
#
# === Examples
#
#  class { 'osg::tomcat': }
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2013 Trey Dockendorf
#
class osg::tomcat (

) inherits osg {

  include osg::repo
  include osg::params

  Class['osg::repo'] -> Class['osg::tomcat']

  ensure_packages($osg::params::tomcat_packages)

  service { 'tomcat6':
    ensure      => running,
    enable      => true,
    hasstatus   => true,
    hasrestart  => true,
    require     => Package['tomcat6'],
  }
}
