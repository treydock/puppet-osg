# Private class: See README.md.
class osg::cvmfs::install {

  package { 'cvmfs':
    ensure => $osg::cvmfs::package_ensure,
    name   => 'osg-oasis',
  }

}
