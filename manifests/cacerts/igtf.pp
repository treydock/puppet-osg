# == Class: osg::cacerts::igtf
#
# Adds the igtf CA cert package for OSG.
#
# === Parameters
#
# [*package_name*]
#   Default:  'igtf-ca-certs',
#
# [*package_ensure*]
#   Default:  'installed',
#
# === Examples
#
#  class { 'osg::cacerts::igtf': }
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2013 Trey Dockendorf
#
class osg::cacerts::igtf (
  $package_name             = $osg::params::ca_cert_packages['igtf'],
  $package_ensure           = 'installed'
) inherits osg::params {

  require 'osg::repo'

  package { 'igtf-ca-certs':
    ensure  => $package_ensure,
    name    => $package_name,
    require => Yumrepo['osg'],
  }

}
