#
# Class: osg::utils: See README.md for documentation.
class osg::utils (
  $packages = $osg::params::utils_packages,
) inherits osg::params {

  include osg

  ensure_packages($packages, {'require' => Class['osg::repos']})

}
