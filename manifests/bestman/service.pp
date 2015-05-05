# Private class: See README.md.
class osg::bestman::service {

  service { 'bestman2':
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }

}
