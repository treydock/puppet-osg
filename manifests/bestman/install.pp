# == Class: osg::bestman::install
#
class osg::bestman::install {

  package { 'osg-se-bestman':
    ensure  => 'installed',
  }

}
