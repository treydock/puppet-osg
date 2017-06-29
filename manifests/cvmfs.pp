# Class: osg::cvmfs: See README.md for documentation.
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
  $manage_fuse_group      = true,
  $fuse_group_name        = 'fuse',
  $fuse_group_gid         = undef,
  $fuse_group_system      = true,
  $package_ensure         = 'installed',
  $repositories           = ['UNSET'],
  $strict_mount           = false,
  $cache_base             = '/var/cache/cvmfs',
  $quota_limit            = '20000',
  $http_proxies           = ["http://squid.${::domain}:3128"],
  $cern_server_urls       = [
    'http://cvmfs-stratum-one.cern.ch:8000/opt/@org@',
    'http://cernvmfs.gridpp.rl.ac.uk:8000/opt/@org@',
    'http://cvmfs.racf.bnl.gov:8000/opt/@org@',
  ],
  $glite_version          = '',
  $cms_local_site         = 'UNSET',
) inherits osg::params {

  validate_bool($manage_user)
  validate_bool($manage_group)
  validate_bool($manage_fuse_group)
  validate_bool($strict_mount)
  validate_array($repositories)
  validate_array($http_proxies)
  validate_array($cern_server_urls)

  $repositories_real = $repositories[0] ? {
    'UNSET' => '`echo $((echo oasis.opensciencegrid.org;echo cms.cern.ch;ls /cvmfs)|sort -u)|tr \' \' ,`',
    default => join($repositories, ','),
  }

  include osg

  anchor { 'osg::cvmfs::start': }
  -> Class['osg']
  -> class { 'osg::cvmfs::user': }
  -> class { 'osg::cvmfs::install': }
  -> class { 'osg::cvmfs::config': }
  -> class { 'osg::cvmfs::service': }
  -> anchor { 'osg::cvmfs::end': }

}
