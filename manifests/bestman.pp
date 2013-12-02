# == Class: osg::bestman
#
# Installs and configures a Bestman SE for use with OSG.
#
# === Parameters
#
# === Examples
#
#  class { 'osg::bestman': }
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2013 Trey Dockendorf
#
class osg::bestman (
  $manage_user            = true,
  $user_name              = 'bestman',
  $user_uid               = 'UNSET',
  $user_home              = '/etc/bestman2',
  $user_shell             = '/bin/bash',
  $user_system            = true,
  $user_comment           = 'BeStMan 2 Server user',
  $user_managehome        = false,
  $manage_group           = true,
  $group_name             = 'bestman',
  $group_gid              = 'UNSET',
  $group_system           = true,
  $with_gridmap_auth      = false,
  $grid_map_file_name     = '/etc/bestman2/conf/grid-mapfile.empty',
  $with_gums_auth         = true,
  $gums_hostname          = 'UNSET',
  $gums_port              = '8443',
  $gums_protocol          = 'XACML',
  $gums_CurrHostDN        = 'UNSET',
  $bestman_gumscertpath   = '/etc/grid-security/bestman/bestmancert.pem',
  $bestman_gumskeypath    = '/etc/grid-security/bestman/bestmankey.pem',
  $globus_hostname        = $::fqdn,
  $event_log_count        = 10,
  $event_log_size         = 20971520,
  $manage_firewall        = true,
  $securePort             = '8443',
  $localPathListToBlock   = [],
  $localPathListAllowed   = [],
  $cert_file_name         = '/etc/grid-security/bestman/bestmancert.pem',
  $key_file_name          = '/etc/grid-security/bestman/bestmankey.pem',
  $supportedProtocolList  = [],
  $noSudoOnLs             = true,
  $accessFileSysViaGsiftp = false,
  $manage_sudo            = true,
  $sudo_priority          = 10,
  $sudo_srm_commands      = $osg::params::sudo_srm_commands,
  $sudo_srm_runas         = $osg::params::sudo_srm_runas,
  $service_ensure         = 'undef',
  $service_enable         = true,
  $service_autorestart    = true
) inherits osg::params {

  validate_bool($manage_user)
  validate_bool($manage_group)
  validate_bool($with_gridmap_auth)
  validate_bool($with_gums_auth)
  validate_bool($manage_firewall)
  validate_bool($manage_sudo)
  validate_array($localPathListToBlock)
  validate_array($localPathListAllowed)
  validate_array($supportedProtocolList)

  if $with_gridmap_auth and $with_gums_auth {
    fail('with_gridmap_auth and with_gums_auth cannot both be true')
  }

  $user_uid_real = $user_uid ? {
    /UNSET|undef/ => undef,
    default       => $user_uid,
  }

  $group_gid_real = $group_gid ? {
    /UNSET|undef/ => undef,
    default       => $group_gid,
  }

  $sudo_srm_cmd = is_string($sudo_srm_commands) ? {
    true  => $sudo_srm_commands,
    false => join($sudo_srm_commands, ',')
  }

  $sudo_srm_usr = is_string($sudo_srm_runas) ? {
    true  => $sudo_srm_runas,
    false => join($sudo_srm_runas, ',')
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
    true  => Service['bestman2'],
    false => undef,
  }

  include osg::cacerts

  if $with_gums_auth {
    require 'osg::lcmaps'

    $gums_hostname_real = $gums_hostname ? {
      'UNSET' => $osg::lcmaps::gums_hostname,
      default => $gums_hostname,
    }
  }

  if $manage_firewall {
    firewall { '100 allow SRMv2 access':
      port    => $securePort,
      proto   => tcp,
      action  => accept,
    }
  }

  if $manage_sudo {
    sudo::conf { 'bestman':
      priority  => $sudo_priority,
      content   => template('osg/bestman/bestman.sudo.erb'),
    }
  }

  if $manage_user {
    user { 'bestman':
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
    group { 'bestman':
      ensure  => present,
      name    => $group_name,
      gid     => $group_gid_real,
      system  => $group_system,
    }
  }

  package { 'osg-se-bestman':
    ensure  => installed,
    before  => [ File['/etc/sysconfig/bestman2'], File['/etc/bestman2/conf/bestman2.rc'] ],
    require => [ Yumrepo['osg'], Package['osg-ca-certs'] ],
  }

  file { '/etc/sysconfig/bestman2':
    ensure  => present,
    content => template('osg/bestman/bestman2.sysconfig.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => $file_notify,
  }

  file { '/etc/bestman2/conf/bestman2.rc':
    ensure  => present,
    content => template('osg/bestman/bestman2.rc.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => $file_notify,
  }

  service { 'bestman2':
    ensure      => $service_ensure_real,
    enable      => $service_enable_real,
    hasstatus   => true,
    hasrestart  => true,
    require     => [ File['/etc/sysconfig/bestman2'], File['/etc/bestman2/conf/bestman2.rc'] ],
  }

  if $bestman_gumscertpath == $cert_file_name {
    file { $bestman_gumscertpath:
      owner   => $user_name,
      group   => $group_name,
      mode    => '0444',
      require => Package['osg-se-bestman'],
    }
  } else {
    file { $bestman_gumscertpath:
      owner   => $user_name,
      group   => $group_name,
      mode    => '0444',
      require => Package['osg-se-bestman'],
    }

    file { $cert_file_name:
      owner   => $user_name,
      group   => $group_name,
      mode    => '0444',
      require => Package['osg-se-bestman'],
    }
  }

  if $bestman_gumskeypath == $key_file_name {
    file { $bestman_gumskeypath:
      owner   => $user_name,
      group   => $group_name,
      mode    => '0400',
      require => Package['osg-se-bestman'],
    }
  } else {
    file { $bestman_gumskeypath:
      owner   => $user_name,
      group   => $group_name,
      mode    => '0400',
      require => Package['osg-se-bestman'],
    }

    file { $key_file_name:
      owner   => $user_name,
      group   => $group_name,
      mode    => '0400',
      require => Package['osg-se-bestman'],
    }
  }

  file { '/var/log/bestman2':
    ensure  => directory,
    owner   => $user_name,
    group   => $group_name,
    mode    => '0755',
    require => Package['osg-se-bestman'],
  }
}
