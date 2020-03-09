# @summary Manage OSG utils
#
# @param packages
#   Packages to install
#
class osg::utils (
  Array $packages = [
    'globus-proxy-utils',
    'osg-pki-tools',
  ],
) {

  include osg

  ensure_packages($packages, {'require' => Class['osg::repos']})

}
