# Private class: See README.md.
class osg::rsv::service {

  service { 'rsv':
    ensure     => 'running',
    enable     => true,
    hasstatus  => false,
    hasrestart => true,
    status     => 'test -f /var/lock/subsys/rsv',
  }

  service { 'condor-cron':
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    before     => Service['rsv'],
  }

}
