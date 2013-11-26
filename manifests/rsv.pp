# == Class: osg::rsv
#
# Installs and configures RSV for use with OSG.
#
# === Parameters
#
# === Examples
#
#  class { 'osg::rsv': }
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2013 Trey Dockendorf
#
class osg::rsv (
  $manage_user            = true,
  $user_name              = 'rsv',
  $user_uid               = 'UNSET',
  $user_home              = '/var/rsv',
  $user_shell             = '/bin/sh',
  $user_system            = true,
  $user_comment           = 'RSV monitoring',
  $user_managehome        = false,
  $manage_group           = true,
  $group_name             = 'rsv',
  $group_gid              = 'UNSET',
  $group_system           = true,
  $service_cert           = '/etc/grid-security/rsv/rsvcert.pem',
  $service_key            = '/etc/grid-security/rsv/rsvkey.pem',
  $service_proxy          = '/tmp/rsvproxy',
  $with_httpd             = true,
  $manage_firewall        = true,
  $http_port              = '80',
  $service_ensure         = 'undef',
  $service_enable         = true,
  $service_autorestart    = true,
  $with_osg_configure     = true,
  $config_replace         = false,
  $configd_replace        = true,
  $enable_gratia          = true,
  $ce_hosts               = 'UNAVAILABLE',
  $gridftp_hosts          = 'UNAVAILABLE',
  $gridftp_dir            = 'DEFAULT',
  $gratia_probes          = 'UNAVAILABLE',
  $gums_hosts             = 'UNAVAILABLE',
  $srm_hosts              = 'UNAVAILABLE',
  $srm_dir                = 'DEFAULT',
  $srm_webservice_path    = 'DEFAULT',
  $enable_local_probes    = true
) inherits osg::params {

  validate_bool($manage_user)
  validate_bool($manage_group)
  validate_bool($with_httpd)
  validate_bool($manage_firewall)
  validate_bool($with_osg_configure)
  validate_bool($config_replace)
  validate_bool($configd_replace)
  validate_bool($enable_gratia)
  validate_bool($enable_local_probes)

  $user_uid_real = $user_uid ? {
    /UNSET|undef/ => undef,
    default       => $user_uid,
  }

  $group_gid_real = $group_gid ? {
    /UNSET|undef/ => undef,
    default       => $group_gid,
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
    true  => Service['rsv'],
    false => undef,
  }

  $configd_notify = $with_osg_configure ? {
    true  => Exec['osg-configure-rsv'],
    false => undef,
  }

  if $enable_gratia {
    $enable_gratia_real = 'True'
  } else {
    $enable_gratia_real = 'False'
  }

  if $enable_local_probes {
    $enable_local_probes_real = 'True'
  } else {
    $enable_local_probes_real = 'False'
  }

  $package_before   = [ File['/etc/rsv/rsv.conf'], File['/etc/rsv/consumers.conf'], File['/etc/osg/config.d/30-rsv.ini'] ]
  $service_require  = [ File['/etc/rsv/rsv.conf'], File['/etc/rsv/consumers.conf'], Service['condor-cron'] ]

  include osg::condor_cron
  include osg::cacerts

  Class['osg::condor_cron'] -> Class['osg::rsv']

  if $with_httpd {
    if $manage_firewall {
      firewall { '100 allow RSV http access':
        port    => $http_port,
        proto   => tcp,
        action  => accept,
      }
    }

    include apache
  }

  exec { 'osg-configure-rsv':
    command     => '/usr/sbin/osg-configure --module=RSV --configure',
    onlyif      => '/usr/sbin/osg-configure --module=RSV --verify',
    user        => 'root',
    refreshonly => true,
  }

  if $manage_user {
    user { 'rsv':
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
    group { 'rsv':
      ensure  => present,
      name    => $group_name,
      gid     => $group_gid_real,
      system  => $group_system,
    }
  }

  package { 'rsv':
    ensure  => installed,
    before  => $package_before,
    require => [ Yumrepo['osg'], Package['osg-ca-certs'] ],
  }

  file { '/etc/osg/config.d/30-rsv.ini':
    ensure  => present,
    content => template('osg/config.d/30-rsv.ini.erb'),
    replace => $configd_replace,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => $configd_notify,
  }

  file { '/etc/rsv/rsv.conf':
    ensure  => present,
    content => template('osg/rsv/rsv.conf.erb'),
    replace => $config_replace,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => $file_notify,
  }

  file { '/etc/rsv/consumers.conf':
    ensure  => present,
    content => template('osg/rsv/consumers.conf.erb'),
    replace => $config_replace,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => $file_notify,
  }

  service { 'rsv':
    ensure      => $service_ensure_real,
    enable      => $service_enable_real,
    hasstatus   => false,
    hasrestart  => true,
    status      => 'test -f /var/lock/subsys/rsv',
    require     => $service_require,
  }

  file { $service_cert:
    owner   => $user_name,
    group   => $group_name,
    mode    => '0444',
    require => Package['rsv'],
  }

  file { $service_key:
    owner   => $user_name,
    group   => $group_name,
    mode    => '0400',
    require => Package['rsv'],
  }

  file { '/var/spool/rsv':
    ensure  => directory,
    owner   => $user_name,
    group   => $group_name,
    mode    => '0755',
    require => Package['rsv'],
  }

  file { '/var/tmp/rsv':
    ensure  => directory,
    owner   => $user_name,
    group   => $group_name,
    mode    => '0755',
    require => Package['rsv'],
  }

  file { '/var/log/rsv':
    ensure  => directory,
    owner   => $user_name,
    group   => $group_name,
    mode    => '0755',
    require => Package['rsv'],
  }

  file { '/var/log/rsv/consumers':
    ensure  => directory,
    owner   => $user_name,
    group   => $group_name,
    mode    => '0755',
    require => File['/var/log/rsv'],
  }

  file { '/var/log/rsv/metrics':
    ensure  => directory,
    owner   => $user_name,
    group   => $group_name,
    mode    => '0755',
    require => File['/var/log/rsv'],
  }
}
