# == Class: osg::cacerts::updater
#
# Adds the basic CA cert packages and services for OSG.
#
# === Parameters
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
  $replace_config           = true
) inherits osg::params {

  include osg::repo
  include osg::cacerts

  Class['osg::cacerts'] -> Class['osg::cacerts::updater']

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
}
