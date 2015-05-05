# Private class: See README.md.
class osg::cvmfs::install {

  package { 'cvmfs':
    ensure => 'installed',
    name   => 'osg-oasis',
  }

}
