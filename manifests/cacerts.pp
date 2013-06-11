# == Class: osg::cacerts
#
# Adds the basic CA cert packages and services for OSG.
#
# === Examples
#
#  class { 'osg::cacerts': }
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2013 Trey Dockendorf
#
class osg::cacerts (

) inherits osg {

  include osg::repo

  package { 'osg-ca-certs':
    ensure  => latest,
    require => Yumrepo['osg'],
  }

  package { 'fetch-crl':
    ensure  => installed,
    require => Yumrepo['osg'],
  }

  service { 'fetch-crl-boot':
    ensure      => running,
    enable      => true,
    hasstatus   => true,
    hasrestart  => true,
    require     => Package['fetch-crl'],
  }

  service { 'fetch-crl-cron':
    ensure      => running,
    enable      => true,
    hasstatus   => true,
    hasrestart  => true,
    require     => Package['fetch-crl'],
  }
}
