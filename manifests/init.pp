# == Class: osg
#
# Base class for OSG stack.
#
# === Parameters
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
  $baseurl        = $osg::params::baseurl,
  $mirrorlist     = $osg::params::mirrorlist
) inherits osg::params {

  include osg::repo

}
