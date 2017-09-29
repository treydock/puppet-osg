# Class: osg::cvmfs: See README.md for documentation.
class osg::cvmfs (
  Boolean $manage_user = true,
  String $user_name = 'cvmfs',
  Optional[Integer] $user_uid = undef,
  String $user_home = '/var/lib/cvmfs',
  String $user_shell = '/sbin/nologin',
  Boolean $user_system = true,
  String $user_comment = 'CernVM-FS service account',
  Boolean $user_managehome = false,
  Boolean $manage_group = true,
  String $group_name = 'cvmfs',
  Optional[Integer] $group_gid = undef,
  Boolean $group_system = true,
  Boolean $manage_fuse_group = true,
  String $fuse_group_name = 'fuse',
  Optional[Integer] $fuse_group_gid = undef,
  Boolean $fuse_group_system = true,
  String $package_ensure = 'installed',
  Optional[Array] $repositories = undef,
  Boolean $strict_mount = false,
  String $cache_base = '/var/cache/cvmfs',
  Integer $quota_limit = 20000,
  Array $http_proxies = ["http://squid.${::domain}:3128"],
  Array $cern_server_urls = [],
  String $glite_version = '',
  Optional[String] $cms_local_site = undef,
) inherits osg::params {

  if $repositories {
    $repositories_real = join($repositories, ',')
  } else {
    $repositories_real = '`echo $((echo oasis.opensciencegrid.org;echo cms.cern.ch;ls /cvmfs)|sort -u)|tr \' \' ,`'
  }

  include ::autofs
  include osg

  anchor { 'osg::cvmfs::start': }
  -> Class['osg']
  -> class { 'osg::cvmfs::user': }
  -> class { 'osg::cvmfs::install': }
  -> class { 'osg::cvmfs::config': }
  -> class { 'osg::cvmfs::service': }
  -> anchor { 'osg::cvmfs::end': }

}
