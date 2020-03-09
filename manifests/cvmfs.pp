# @summary Manage OSG CVMFS
#
# @param manage_user
#   Boolean to set if CVMFS user is managed
# @param user_name
#   CVMFS user name
# @param user_uid
#   CVMFS user UID
# @param user_home
#   CVMFS user home
# @param user_shell
#   CVMFS user shell
# @param user_system
#   Sets if CVMFS user is a system account
# @param user_comment
#   CVMFS user comment
# @param user_managehome
#   Sets if CVMFS user home is managed
# @param manage_group
#   Boolean to set if CVMFS group is managed
# @param group_name
#   CVMFS group name
# @param group_gid
#   CVMFS group GID
# @param group_system
#   Sets if CVMFS group is a system account
# @param manage_fuse_group
#   Manage FUSE group
# @param fuse_group_name
#   FUSE group name
# @param fuse_group_gid
#   FUSE group GID
# @param fuse_group_system
#   Sets if FUSE group is a system account
# @param package_ensure
#   Ensure property for CVMFS package
# @param repositories
#   CVMFS repositories to enable, eg: `grid.cern.ch`
# @param strict_mount
#   Enable CVMFS strict mount, only allow mounting repositories from `repositories` parameter
# @param cache_base
#   Base directory for CVMFS cache
# @param quota_limit
#   Quota limit for CVMFS cache
# @param http_proxies
#   Squid HTTP proxies for CVMFS
# @param cern_server_urls
#   Value for `CVMFS_SERVER_URL`
# @param glite_version
#   glite version
# @param cms_local_site
#   Value for `CMS_LOCAL_SITE`
#
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
  Array $http_proxies = ["http://squid.${facts['networking']['domain']}:3128"],
  Array $cern_server_urls = [],
  String $glite_version = '',
  Optional[String] $cms_local_site = undef,
) {

  if $repositories {
    $repositories_real = join($repositories, ',')
  } else {
    $repositories_real = '`echo $((echo oasis.opensciencegrid.org;echo cms.cern.ch;ls /cvmfs)|sort -u)|tr \' \' ,`'
  }

  include ::autofs
  include osg
  contain osg::cvmfs::user
  contain osg::cvmfs::install
  contain osg::cvmfs::config
  contain osg::cvmfs::service

  Class['osg']
  -> Class['osg::cvmfs::user']
  -> Class['osg::cvmfs::install']
  -> Class['osg::cvmfs::config']
  -> Class['osg::cvmfs::service']

}
