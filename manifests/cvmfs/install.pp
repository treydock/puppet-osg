# == Class: osg::cvmfs::install
#
class osg::cvmfs::install {

  package { 'cvmfs':
    ensure => 'installed',
    name   => 'osg-oasis',
  }

}
