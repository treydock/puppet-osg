# == Class: osg::cacerts::empty
#
# Adds the empty CA cert package for OSG.
#
# === Parameters
#
# [*package_name*]
#   Default:  'empty-ca-certs',
#
# [*package_ensure*]
#   Default:  'installed',
#
# === Examples
#
#  class { 'osg::cacerts::empty': }
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2013 Trey Dockendorf
#
class osg::cacerts::empty (
  $package_name             = $osg::params::ca_cert_packages['empty'],
  $package_ensure           = 'installed'
) inherits osg::params {

  require 'osg::repo'

  package { 'empty-ca-certs':
    ensure  => $package_ensure,
    name    => $package_name,
    require => Yumrepo['osg'],
  }

}
