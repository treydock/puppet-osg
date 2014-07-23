# == Class: osg::gums::install
#
class osg::gums::install {

  package { 'osg-gums':
    ensure  => installed,
  }

}
