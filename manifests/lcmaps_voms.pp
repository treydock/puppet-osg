#
class osg::lcmaps_voms (
  Array $ban_voms = [],
  Array $ban_users = [],
  Hash[String, Variant[String, Array, Hash]] $vos = {},
  Hash[String, Variant[String, Array, Hash]] $users = {},
) inherits osg::params {

  include ::osg
  include ::osg::cacerts

  anchor { 'osg::lcmaps_voms::start': }
  -> Class['::osg']
  -> Class['::osg::cacerts']
  -> class { '::osg::lcmaps_voms::install': }
  -> class { '::osg::lcmaps_voms::config': }
  -> anchor { 'osg::lcmaps_voms::end': }

  $vos.each |$vo, $dn| {
    if $dn =~ String or $dn =~ Array {
      osg::lcmaps_voms::vo { $vo: dn => $dn }
    } else {
      ensure_resource('osg::lcmaps_voms::vo', $vo, $dn)
    }
  }

  $users.each |$user, $dn| {
    if $dn =~ String or $dn =~ Array {
      osg::lcmaps_voms::user { $user: dn => $dn }
    } else {
      ensure_resource('osg::lcmaps_voms::user', $user, $dn)
    }
  }

}
