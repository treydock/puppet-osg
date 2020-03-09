# @summary Manage lcmaps VOMs user
#
# @param dn
#   DN of the user
# @param user
#   Name of the user
# @param order
#   Order in the grid-mapfile
#
define osg::lcmaps_voms::user (
  Variant[Array, String] $dn,
  String $user = $name,
  Integer $order = 50,
) {

  concat::fragment { "osg::lcmaps_voms::user-${name}":
    target  => '/etc/grid-security/grid-mapfile',
    content => template('osg/lcmaps_voms/mapfile.erb'),
    order   => $order,
  }

}
