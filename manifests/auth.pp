#
class osg::auth {

  include ::osg

  if $::osg::auth_type == 'gums' {
    contain osg::gums::client
  } else {
    contain osg::lcmaps_voms
  }

}
