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
