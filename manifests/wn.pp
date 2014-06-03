# == Class: osg::wn
#
class osg::wn inherits osg::params {

  include osg
  include osg::cacerts

  package { 'osg-wn-client':
    ensure  => 'present',
  }

  anchor { 'osg::wn::start': }
  anchor { 'osg::wn::end': }

  Anchor['osg::wn::start']->
  Class['osg']->
  Class['osg::cacerts']->
  Package['osg-wn-client']->
  Anchor['osg::wn::end']

}
