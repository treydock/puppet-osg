# @summary Install lcmaps voms support
# @api private
class osg::lcmaps_voms::install {

  package { 'lcmaps':
    ensure => 'present',
  }
  package { 'vo-client-lcmaps-voms':
    ensure => 'present',
  }
}
