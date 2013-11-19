# == Class: osg::condor_cron
#
# Installs and configures condor-cron for use with OSG.
#
# === Parameters
#
# === Examples
#
#  class { 'osg::condor_cron': }
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2013 Trey Dockendorf
#
class osg::condor_cron (
  $manage_user            = true,
  $user_name              = 'cndrcron',
  $user_uid               = 'UNSET',
  $user_home              = '/var/lib/condor-cron',
  $user_shell             = '/sbin/nologin',
  $user_system            = true,
  $user_comment           = 'Condor-cron service',
  $user_managehome        = false,
  $manage_group           = true,
  $group_name             = 'cndrcron',
  $group_gid              = 'UNSET',
  $group_system           = true,
  $ca_certs_type          = 'empty',
  $service_ensure         = 'undef',
  $service_enable         = true,
  $service_autorestart    = true,
  $config_replace         = false
) inherits osg::params {

  validate_bool($manage_user)
  validate_bool($manage_group)
  validate_re($ca_certs_type, '^(osg|igtf|empty)$')
  validate_bool($config_replace)

  $user_uid_real = $user_uid ? {
    /UNSET|undef/ => undef,
    default       => $user_uid,
  }

  $group_gid_real = $group_gid ? {
    /UNSET|undef/ => undef,
    default       => $group_gid,
  }

  $ca_certs_class = $ca_certs_type ? {
    /igtf/  => 'osg::cacerts::igtf',
    /osg/   => 'osg::cacerts',
    default => 'osg::cacerts::empty',
  }

  # This gives the option to not manage the service 'ensure' state.
  $service_ensure_real = $service_ensure ? {
    /UNSET|undef/ => undef,
    default       => $service_ensure,
  }

  # This gives the option to not manage the service 'enable' state.
  $service_enable_real = $service_enable ? {
    /UNSET|undef/ => undef,
    default       => $service_enable,
  }

  $file_notify = $service_autorestart ? {
    true  => Service['condor-cron'],
    false => undef,
  }

  if $user_uid_real and $group_gid_real {
    $package_before     = [ File['/etc/condor-cron/config.d/condor_ids'], File['/etc/condor-cron/condor_config'] ]
    $service_require    = [ File['/etc/condor-cron/config.d/condor_ids'], File['/etc/condor-cron/condor_config'] ]
    $manage_condor_ids  = true
  } else {
    $package_before     = File['/etc/condor-cron/condor_config']
    $service_require    = File['/etc/condor-cron/condor_config']
    $manage_condor_ids  = false
  }

  require $ca_certs_class

  if $manage_user {
    user { 'cndrcron':
      ensure      => 'present',
      name        => $user_name,
      uid         => $user_uid_real,
      home        => $user_home,
      shell       => $user_shell,
      system      => $user_system,
      comment     => $user_comment,
      managehome  => $user_managehome,
    }
  }

  if $manage_group {
    group { 'cndrcron':
      ensure  => present,
      name    => $group_name,
      gid     => $group_gid_real,
      system  => $group_system,
    }
  }

  package { 'condor-cron':
    ensure  => installed,
    before  => $package_before,
    require => [ Yumrepo['osg'], Package[$osg::params::ca_cert_packages[$ca_certs_type]] ],
  }

  if $manage_condor_ids {
    file { '/etc/condor-cron/config.d/condor_ids':
      ensure  => present,
      content => template('osg/condor_cron/condor_ids.erb'),
      replace => $config_replace,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      notify  => $file_notify,
    }
  }

  file { '/etc/condor-cron/condor_config':
    ensure  => present,
    content => template('osg/condor_cron/condor_config.erb'),
    replace => $config_replace,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => $file_notify,
  }

  service { 'condor-cron':
    ensure      => $service_ensure_real,
    enable      => $service_enable_real,
    hasstatus   => true,
    hasrestart  => true,
    require     => $service_require,
  }

  file { '/var/lib/condor-cron':
    ensure  => directory,
    path    => $user_home,
    owner   => $user_name,
    group   => $group_name,
    mode    => '0755',
    require => Package['condor-cron']
  }

  file { '/var/lib/condor-cron/execute':
    ensure  => directory,
    path    => "${user_home}/execute",
    owner   => $user_name,
    group   => $group_name,
    mode    => '0755',
    require => File['/var/lib/condor-cron']
  }

  file { '/var/lib/condor-cron/spool':
    ensure  => directory,
    path    => "${user_home}/spool",
    owner   => $user_name,
    group   => $group_name,
    mode    => '0755',
    require => File['/var/lib/condor-cron']
  }

  file { '/var/run/condor-cron':
    ensure  => directory,
    owner   => $user_name,
    group   => $group_name,
    mode    => '0755',
    require => Package['condor-cron'],
  }

  file { '/var/lock/condor-cron':
    ensure  => directory,
    owner   => $user_name,
    group   => $group_name,
    mode    => '0755',
    require => Package['condor-cron'],
  }

  file { '/var/log/condor-cron':
    ensure  => directory,
    owner   => $user_name,
    group   => $group_name,
    mode    => '0755',
    require => Package['condor-cron'],
  }
}
