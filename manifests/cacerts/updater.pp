# Class: osg::cacerts::updater: See README.md for documentation.
class osg::cacerts::updater (
  $ensure                   = 'present',
  $min_age                  = '23',
  $max_age                  = '72',
  $random_wait              = '30',
  $quiet                    = true,
  $logfile                  = false,
  $package_name             = 'osg-ca-certs-updater',
  $package_ensure           = 'UNSET',
  $service_name             = 'osg-ca-certs-updater-cron',
  $service_ensure           = 'UNSET',
  $service_enable           = 'UNSET',
  $include_cron             = true,
  $config_replace           = true,
  $crl_package_name         = 'fetch-crl',
  $crl_package_ensure       = 'UNSET',
  $crl_boot_service_name    = 'fetch-crl-boot',
  $crl_boot_service_ensure  = 'stopped',
  $crl_boot_service_enable  = false,
  $crl_cron_service_name    = 'fetch-crl-cron',
  $crl_cron_service_ensure  = 'UNSET',
  $crl_cron_service_enable  = 'UNSET',
) inherits osg::params {

  require 'osg::cacerts'

  validate_bool($include_cron)
  validate_bool($config_replace)

  case $ensure {
    'present': {
      $package_ensure_default = 'installed'
      $service_ensure_default = 'running'
      $service_enable_default = true
    }
    'absent': {
      $package_ensure_default = 'absent'
      $service_ensure_default = 'stopped'
      $service_enable_default = false
    }
    'disabled': {
      $package_ensure_default = 'installed'
      $service_ensure_default = 'stopped'
      $service_enable_default = false
    }
    default: {
      fail("Module osg::cacerts::updater: Parameter 'ensure' must be 'present', 'absent' or 'disabled': ${ensure} given")
    }
  }

  $package_ensure_real = $package_ensure ? {
    'UNSET' => $package_ensure_default,
    default => $package_ensure,
  }

  $crl_package_ensure_real = $crl_package_ensure ? {
    'UNSET' => $package_ensure_default,
    default => $crl_package_ensure,
  }

  $service_ensure_real = $service_ensure ? {
    'UNSET' => $service_ensure_default,
    default => $service_ensure,
  }

  $service_enable_real = $service_enable ? {
    'UNSET' => $service_enable_default,
    default => $service_enable,
  }

  $crl_boot_service_ensure_real = $crl_boot_service_ensure ? {
    'UNSET' => $service_ensure_default,
    default => $crl_boot_service_ensure,
  }

  $crl_boot_service_enable_real = $crl_boot_service_enable ? {
    'UNSET' => $service_enable_default,
    default => $crl_boot_service_enable,
  }

  $crl_cron_service_ensure_real = $crl_cron_service_ensure ? {
    'UNSET' => $service_ensure_default,
    default => $crl_cron_service_ensure,
  }

  $crl_cron_service_enable_real = $crl_cron_service_enable ? {
    'UNSET' => $service_enable_default,
    default => $crl_cron_service_enable,
  }

  $min_age_arg = $min_age ? {
    /undef|false/ => 'UNSET',
    default       => "-a ${min_age}",
  }
  $max_age_arg = $max_age ? {
    /undef|false/ => 'UNSET',
    default       => "-x ${max_age}",
  }
  $random_wait_arg = $random_wait ? {
    /undef|false/ => 'UNSET',
    default       => "-r ${random_wait}",
  }
  $quiet_arg = $quiet ? {
    true          => '-q',
    default       => 'UNSET',
  }
  $logfile_arg = $logfile ? {
    false   => 'UNSET',
    'undef' => 'UNSET',
    default => "-l ${logfile}",
  }

  $args_array = [ $min_age_arg, $max_age_arg, $random_wait_arg, $quiet_arg, $logfile_arg ]
  $args = join(reject($args_array, 'UNSET'), ' ')

  if $include_cron { include cron }

  package { 'osg-ca-certs-updater':
    ensure  => $package_ensure_real,
    name    => $package_name,
    before  => File['/etc/cron.d/osg-ca-certs-updater'],
    require => Yumrepo['osg'],
  }

  service { 'osg-ca-certs-updater-cron':
    ensure     => $service_ensure_real,
    enable     => $service_enable_real,
    name       => $service_name,
    hasstatus  => true,
    hasrestart => true,
    subscribe  => File['/etc/cron.d/osg-ca-certs-updater'],
  }

  file { '/etc/cron.d/osg-ca-certs-updater':
    ensure  => present,
    content => template('osg/osg-ca-certs-updater.erb'),
    replace => $config_replace,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package[$osg::params::crond_package_name],
  }

  package { 'fetch-crl':
    ensure  => $crl_package_ensure_real,
    name    => $crl_package_name,
    require => Yumrepo['osg'],
  }

  service { 'fetch-crl-boot':
    ensure     => $crl_boot_service_ensure_real,
    enable     => $crl_boot_service_enable_real,
    name       => $crl_boot_service_name,
    hasstatus  => true,
    hasrestart => true,
    require    => Package['fetch-crl'],
  }

  service { 'fetch-crl-cron':
    ensure     => $crl_cron_service_ensure_real,
    enable     => $crl_cron_service_enable_real,
    name       => $crl_cron_service_name,
    hasstatus  => true,
    hasrestart => true,
    require    => Package['fetch-crl'],
  }
}
