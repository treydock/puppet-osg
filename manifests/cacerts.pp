# == Class: osg::cacerts
#
# Adds the basic CA cert packages and services for OSG.
#
# === Parameters
#
# [*package_name*]
#   Default:  'osg-ca-certs',
#
# [*package_ensure*]
#   Default:  'latest',
#
# [*crl_package_name*]
#   Default:  'fetch-crl',
#
# [*crl_package_ensure*]
#   Default:  'installed',
#
# [*crl_boot_service_name*]
#   Default:  'fetch-crl-boot',
#
# [*crl_boot_service_ensure*]
#   Default:  'running',
#
# [*crl_boot_service_enable*]
#   Default:  true,
#
# [*crl_cron_service_name*]
#   Default:  'fetch-crl-cron',
#
# [*crl_cron_service_ensure*]
#   Default:  'running',
#
# [*crl_cron_service_enable*]
#   Default:  true
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
  $package_ensure           = 'latest',
  $crl_package_name         = 'fetch-crl',
  $crl_package_ensure       = 'installed',
  $crl_boot_service_name    = 'fetch-crl-boot',
  $crl_boot_service_ensure  = 'running',
  $crl_boot_service_enable  = true,
  $crl_cron_service_name    = 'fetch-crl-cron',
  $crl_cron_service_ensure  = 'running',
  $crl_cron_service_enable  = true
) inherits osg {

  include osg::repo

  package { 'osg-ca-certs':
    ensure  => $package_ensure,
    name    => $package_name,
    require => Yumrepo['osg'],
  }

  package { 'fetch-crl':
    ensure  => $crl_package_ensure,
    name    => $crl_package_name,
    require => Yumrepo['osg'],
  }

  service { 'fetch-crl-boot':
    ensure      => $crl_boot_service_ensure,
    enable      => $crl_boot_service_enable,
    name        => $crl_boot_service_name,
    hasstatus   => true,
    hasrestart  => true,
    require     => Package['fetch-crl'],
  }

  service { 'fetch-crl-cron':
    ensure      => $crl_cron_service_ensure,
    enable      => $crl_cron_service_enable,
    name        => $crl_cron_service_name,
    hasstatus   => true,
    hasrestart  => true,
    require     => Package['fetch-crl'],
  }
}
