# == Class: osg
#
# Base class for OSG stack.
#
# === Parameters
#
# [*osg_release*]
#   String.  The release version to use for the OSG repositories.
#   Default: '3.0'
#
# [*baseurl*]
#   The baseurl used for the OSG yum repo.
#   Default: undef
#
# [*mirrorlist*]
#   The mirrorlist used for the OSG yum repo.
#   Set to false to disable this line in the yum repo.
#
# === Examples
#
#  class { 'osg': }
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2013 Trey Dockendorf
#
class osg (
  $osg_release    = '3.0',
  $baseurl        = 'UNSET',
  $mirrorlist     = 'UNSET',
  $gums_host      = "gums.${::domain}",
  $shared_certs_path = '/apps/osg3/grid-security/certificates',
) inherits osg::params {

  validate_re($osg_release, '^(3.0|3.1|3.2)$', 'The $osg_release parameter only supports 3.0, 3.1, and 3.2')

  $baseurl_real = $baseurl ? {
    'UNSET' => 'UNSET',
    default => $baseurl,
  }
  $mirrorlist_real = $mirrorlist ? {
    'UNSET' => $osg_release ? {
      '3.0'   => "http://repo.grid.iu.edu/mirror/3.0/el${::os_maj_version}/osg-release/${::architecture}",
      default => "http://repo.grid.iu.edu/mirror/osg/${osg_release}/el${::os_maj_version}/release/${::architecture}",
    },
    default => $mirrorlist,
  }

  include osg::repo

  Osg_config<| |> ~> Exec['osg-configure']

  exec { 'osg-configure':
    path        => ['/usr/bin','/bin','/usr/sbin','/sbin'],
    command     => '/usr/sbin/osg-configure -c',
    onlyif      => ['test -f /usr/sbin/osg-configure', '/usr/sbin/osg-configure -v'],
    refreshonly => true,
  }

}
