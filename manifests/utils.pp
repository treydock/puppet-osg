# @summary Manage OSG utils
#
# @param packages
#   Packages to install
#
class osg::utils (
  Array $packages = $osg::params::utils_packages,
) inherits osg::params {

  include osg

  ensure_packages($packages, {'require' => Class['osg::repos']})

}
