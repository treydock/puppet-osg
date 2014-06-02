# == Class: osg::rsv::install
#
class osg::rsv::install {

  package { 'rsv':
    ensure  => 'installed',
  }

}
