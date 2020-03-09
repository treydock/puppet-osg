# @summary Manage OSG fetchcrl
#
# @param ensure
#   State of OSG fetchcrl
#   `disabled` will install but disable service
# @param crl_package_name
#   fetch-crl package name
# @param crl_package_ensure
#   Ensure property for fetch-crl package
# @param crl_boot_service_name
#   fetch-crl-boot package name
# @param crl_boot_service_ensure
#   fetch-crl-boot service ensure
# @param crl_boot_service_enable
#   fetch-crl-boot service enable
# @param crl_cron_service_name
#   fetch-crl-cron service name
# @param crl_cron_service_ensure
#   fetch-crl-cron service ensure
# @param crl_cron_service_enable
#   fetch-crl-cron service enable
# @param use_syslog
#   Boolean to set if syslog should be used
#
class osg::fetchcrl (
  Enum['present', 'absent', 'disabled'] $ensure = 'present',
  String $crl_package_name = 'fetch-crl',
  String $crl_package_ensure = 'UNSET',
  String $crl_boot_service_name = 'fetch-crl-boot',
  String $crl_boot_service_ensure = 'stopped',
  Boolean $crl_boot_service_enable = false,
  String $crl_cron_service_name = 'fetch-crl-cron',
  String $crl_cron_service_ensure = 'UNSET',
  Variant[Boolean, Enum['UNSET']] $crl_cron_service_enable = 'UNSET',
  Boolean $use_syslog = true,
) inherits osg::params {

  require 'osg'

  case $ensure {
    'present': {
      $package_ensure_default = 'installed'
      $syslog_conf_ensure     = $use_syslog ? {
        true  => 'file',
        false => 'absent',
      }
      $service_ensure_default = 'running'
      $service_enable_default = true
    }
    'absent': {
      $package_ensure_default = 'absent'
      $syslog_conf_ensure     = 'absent'
      $service_ensure_default = 'stopped'
      $service_enable_default = false
    }
    'disabled': {
      $package_ensure_default = 'installed'
      $syslog_conf_ensure     = $use_syslog ? {
        true  => 'file',
        false => 'absent',
      }
      $service_ensure_default = 'stopped'
      $service_enable_default = false
    }
    default: {
      fail("Module osg::fetchcrl: Parameter 'ensure' must be 'present', 'absent' or 'disabled': ${ensure} given")
    }
  }

  $crl_package_ensure_real = $crl_package_ensure ? {
    'UNSET' => $package_ensure_default,
    default => $crl_package_ensure,
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

  package { 'fetch-crl':
    ensure  => $crl_package_ensure_real,
    name    => $crl_package_name,
    require => Yumrepo['osg'],
  }

  file { '/etc/fetch-crl.d/syslog.conf':
    ensure  => $syslog_conf_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('osg/fetchcrl/syslog.conf.erb'),
    require => Package['fetch-crl'],
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
