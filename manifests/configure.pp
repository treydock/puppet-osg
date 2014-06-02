# == Class: osg::configure
#
class osg::configure {

  exec { 'osg-configure':
    path        => ['/usr/bin','/bin','/usr/sbin','/sbin'],
    command     => '/usr/sbin/osg-configure -c',
    onlyif      => ['test -f /usr/sbin/osg-configure', '/usr/sbin/osg-configure -v'],
    refreshonly => true,
  }

}
