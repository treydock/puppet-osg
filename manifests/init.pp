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
  $osg_release      = '3.1',
  $repo_baseurl_bit = 'http://repo.grid.iu.edu',
  $repo_use_mirrors = true,
  $enable_osg_contrib = false,
  $gums_host        = "gums.${::domain}",
  $shared_certs_path = '/opt/grid-certificates',
  $globus_tcp_port_range_min = '40000',
  $globus_tcp_port_range_max = '41999',
  $globus_tcp_source_range_min = '40000',
  $globus_tcp_source_range_max = '41999',
) inherits osg::params {

  validate_re($osg_release, '^(3.0|3.1|3.2)$', 'The osg_release parameter only supports 3.1 and 3.2')
  validate_bool($repo_use_mirrors)
  validate_bool($enable_osg_contrib)

  anchor { 'osg::start': }
  anchor { 'osg::end': }

  include epel
  include osg::repos

  Anchor['osg::start']->
  Yumrepo['epel']->
  Class['osg::repos']->
  Anchor['osg::end']

  include osg::configure

  Osg_config<| |> ~> Exec['osg-configure']

}
