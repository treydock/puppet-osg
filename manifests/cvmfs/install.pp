# @summary Install CVMFS
# @api private
class osg::cvmfs::install {

  package { 'cvmfs':
    ensure => $osg::cvmfs::package_ensure,
    name   => 'osg-oasis',
  }

}
