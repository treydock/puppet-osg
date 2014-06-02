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
  $tomcat_packages  = $osg::params::tomcat_packages
) inherits osg::params {

  include osg

  Class['osg'] -> Class['osg::tomcat']

  ensure_packages($tomcat_packages)

  $tomcat_service_params = {
    'ensure'      => 'running',
    'enable'      => true,
    'hasstatus'   => true,
    'hasrestart'  => true,
    'require'     => Package['tomcat6'],
  }

  ensure_resource('service', 'tomcat6', $tomcat_service_params)

}
