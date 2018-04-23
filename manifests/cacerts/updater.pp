# Class: osg::cacerts::updater: See README.md for documentation.
class osg::cacerts::updater (
  Enum['present', 'absent', 'disabled'] $ensure = 'present',
  Integer $min_age = 23,
  Integer $max_age = 72,
  Integer $random_wait = 30,
  Boolean $quiet = true,
  Variant[Boolean,Undef,String] $logfile = false,
  String $package_name = 'osg-ca-certs-updater',
  String $package_ensure = 'UNSET',
  String $service_name = 'osg-ca-certs-updater-cron',
  String $service_ensure = 'UNSET',
  String $service_enable = 'UNSET',
  Boolean $config_replace = true,
) inherits osg::params {

  require 'osg::cacerts'

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

  $service_ensure_real = $service_ensure ? {
    'UNSET' => $service_ensure_default,
    default => $service_ensure,
  }

  $service_enable_real = $service_enable ? {
    'UNSET' => $service_enable_default,
    default => $service_enable,
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
  }
}
