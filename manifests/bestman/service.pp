# == Class: osg::bestman::service
#
class osg::bestman::service {

  service { 'bestman2':
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }

}
