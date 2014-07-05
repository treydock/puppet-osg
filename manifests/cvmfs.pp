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
  $http_proxies           = ["http://squid.${::domain}:3128"],
  $server_urls            = [
    'http://cvmfs-stratum-one.cern.ch:8000/opt/@org@',
    'http://cernvmfs.gridpp.rl.ac.uk:8000/opt/@org@',
    'http://cvmfs.racf.bnl.gov:8000/opt/@org@',
  ],
) inherits osg::params {

  validate_bool($manage_user)
  validate_bool($manage_group)
  validate_array($http_proxies)
  validate_array($server_urls)

  include osg

  anchor { 'osg::cvmfs::start': }->
  Class['osg']->
  class { 'osg::cvmfs::install': }->
  class { 'osg::cvmfs::user': }->
  class { 'osg::cvmfs::config': }->
  class { 'osg::cvmfs::service': }->
  anchor { 'osg::cvmfs::end': }

}
