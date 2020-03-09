# @summary Manage lcmaps VOMs
#
# @param ban_voms
#   VOMs to ban
# @param ban_users
#   Users to ban
# @param vos
#   Define osg::lcmaps_voms::vo resources
#   Example: `{ 'vo' => '/DN' }`
#   Example: `{ 'vo' => { 'dn' => '/DN' } }`
# @param users
#   Define osg::lcmaps_voms::user resources
#   Example: `{ 'user' => '/DN' }`
#   Example: `{ 'user' => { 'dn' => '/DN' } }`
#
class osg::lcmaps_voms (
  Array $ban_voms = [],
  Array $ban_users = [],
  Hash[String, Variant[String, Array, Hash]] $vos = {},
  Hash[String, Variant[String, Array, Hash]] $users = {},
) {

  include osg
  include osg::cacerts
  include osg::configure::misc
  contain osg::lcmaps_voms::install
  contain osg::lcmaps_voms::config

  Class['osg']
  -> Class['osg::cacerts']
  -> Class['osg::configure::misc']
  -> Class['osg::lcmaps_voms::install']
  -> Class['osg::lcmaps_voms::config']

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
