# == Class: osg::cvmfs
#
# Installs and configures a cvmfs client for use with OSG.
#
# === Parameters
#
# === Examples
#
#  class { 'osg::cvmfs': }
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2014 Trey Dockendorf
#
class osg::cvmfs (
  $manage_user            = true,
  $user_name              = 'cvmfs',
  $user_uid               = 'UNSET',
  $user_home              = '/var/lib/cvmfs',
  $user_shell             = '/sbin/nologin',
  $user_system            = true,
  $user_comment           = 'CernVM-FS service account',
  $user_managehome        = false,
  $manage_group           = true,
  $group_name             = 'cvmfs',
  $group_gid              = 'UNSET',
  $group_system           = true,
  $cache_base             = '/var/cache/cvmfs',
  $quota_limit            = '20000',
  $http_proxy             = 'DIRECT',
  $server_url             = 'http://cvmfs-stratum-one.cern.ch:8000/opt/@org@;http://cernvmfs.gridpp.rl.ac.uk:8000/opt/@org@;http://cvmfs.racf.bnl.gov:8000/opt/'
) inherits osg::params {

  validate_bool($manage_user)
  validate_bool($manage_group)

  $user_uid_real = $user_uid ? {
    /UNSET|undef/ => undef,
    default       => $user_uid,
  }

  $group_gid_real = $group_gid ? {
    /UNSET|undef/ => undef,
    default       => $group_gid,
  }

  include osg

  if $manage_user {
    user { 'cvmfs':
      ensure      => 'present',
      name        => $user_name,
      uid         => $user_uid_real,
      gid         => $group_name,
      groups      => ['fuse'],
      home        => $user_home,
      shell       => $user_shell,
      system      => $user_system,
      comment     => $user_comment,
      managehome  => $user_managehome,
      before      => Package['cvmfs'],
    }
  }

  if $manage_group {
    group { 'cvmfs':
      ensure  => present,
      name    => $group_name,
      gid     => $group_gid_real,
      system  => $group_system,
      before  => Package['cvmfs'],
    }
  }

  Package['cvmfs'] -> File['/etc/fuse.conf'] -> File_line['auto.master cvmfs'] -> Service['autofs']
  File_line['auto.master cvmfs'] ~> Service['autofs']

  package { 'cvmfs':
    ensure  => installed,
    name    => 'osg-oasis',
    before  => [ File['/etc/cvmfs/default.local'], File['/etc/cvmfs/domain.d/cern.ch.local'] ],
    require => Yumrepo['osg'],
  }

  file { '/etc/fuse.conf':
    ensure  => present,
    path    => '/etc/fuse.conf',
    content => 'user_allow_other\n',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  file_line { 'auto.master cvmfs':
    ensure  => present,
    path    => '/etc/auto.master',
    line    => '/cvmfs /etc/auto.cvmfs',
    match   => '^/cvmfs.*',
  }

  if !defined(Service['autofs']) {
    service { 'autofs':
      ensure      => 'running',
      enable      => true,
      hasstatus   => true,
      hasrestart  => true,
    }
  }

  file { '/etc/cvmfs/default.local':
    ensure  => present,
    path    => '/etc/cvmfs/default.local',
    content => template('osg/cvmfs/default.local.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  file { '/etc/cvmfs/domain.d/cern.ch.local':
    ensure  => present,
    path    => '/etc/cvmfs/domain.d/cern.ch.local',
    content => template('osg/cvmfs/cern.ch.local.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  exec { 'cvmfs_config reload':
    refreshonly => true,
    path        => '/usr/bin:/usr/sbin:/bin:/sbin',
    subscribe   => [ File['/etc/cvmfs/default.local'], File['/etc/cvmfs/domain.d/cern.ch.local'] ],
  }
}
