# == Class: osg::cacerts::updater
#
# Adds the basic CA cert packages and services for OSG.
#
# === Parameters
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
#  class { 'osg::cacerts::updater': }
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2013 Trey Dockendorf
#
class osg::cacerts::updater (
  $min_age                  = '23',
  $max_age                  = '72',
  $random_wait              = '30',
  $quiet                    = true,
  $logfile                  = false,
  $package_name             = 'osg-ca-certs-updater',
  $package_ensure           = 'installed',
  $service_name             = 'osg-ca-certs-updater-cron',
  $service_ensure           = 'running',
  $service_enable           = true,
  $include_cron             = true,
  $replace_config           = true,
  $crl_package_name         = 'fetch-crl',
  $crl_package_ensure       = 'installed',
  $crl_boot_service_name    = 'fetch-crl-boot',
  $crl_boot_service_ensure  = 'running',
  $crl_boot_service_enable  = true,
  $crl_cron_service_name    = 'fetch-crl-cron',
  $crl_cron_service_ensure  = 'running',
  $crl_cron_service_enable  = true
) inherits osg::params {

  require 'osg::repo'

  $include_cron_real = is_string($include_cron) ? {
    true  => str2bool($include_cron),
    false => $include_cron,
  }
  validate_bool($include_cron_real)

  $min_age_arg = $min_age ? {
    /undef|false/ => '',
    default       => "-a ${min_age}",
  }
  $max_age_arg = $max_age ? {
    /undef|false/ => '',
    default       => "-x ${max_age}",
  }
  $random_wait_arg = $random_wait ? {
    /undef|false/ => '',
    default       => "-r ${random_wait}",
  }
  $quiet_arg = $quiet ? {
    /undef|false/ => '',
    default       => '-q',
  }
  $logfile_arg = $logfile ? {
    /undef|false/ => '',
    default       => "-l ${logfile}",
  }

  $args_array = [ $min_age_arg, $max_age_arg, $random_wait_arg, $quiet_arg, $logfile_arg ]
  $args = join($args_array, ' ')

  if $include_cron_real { include cron }

  package { 'osg-ca-certs-updater':
    ensure  => $package_ensure,
    name    => $package_name,
    before  => File['/etc/cron.d/osg-ca-certs-updater'],
    require => Package['osg-ca-certs'],
  }

  service { 'osg-ca-certs-updater-cron':
    ensure      => $service_ensure,
    enable      => $service_enable,
    name        => $service_name,
    hasstatus   => true,
    hasrestart  => true,
    require     => Package['osg-ca-certs-updater'],
  }

  file { '/etc/cron.d/osg-ca-certs-updater':
    ensure  => present,
    content => template('osg/osg-ca-certs-updater.erb'),
    replace => $replace_config,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package[$osg::params::crond_package_name],
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
