# == Class: osg::gridftp::install
#
class osg::gridftp::install {

  package { 'osg-gridftp':
    ensure  => 'present',
  }

}
