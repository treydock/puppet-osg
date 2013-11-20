# == Class: osg::cacerts
#
# Adds the OSG CA cert packages for OSG.
#
# === Parameters
#
# [*package_name*]
#   Default:  'osg-ca-certs',
#
# [*package_ensure*]
#   Default:  'installed',
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
  $package_name             = 'osg-ca-certs',
  $package_ensure           = 'installed'
) inherits osg::params {

  validate_re($package_name, '^(osg-ca-certs|igtf-ca-certs|empty-ca-certs)$')

  include osg::repo

  package { 'osg-ca-certs':
    ensure  => $package_ensure,
    name    => $package_name,
    require => Yumrepo['osg'],
  }

}
