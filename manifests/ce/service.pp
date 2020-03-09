# @summary Manage OSG CE Services
# @api private
class osg::ce::service {

  service { 'condor-ce':
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    subscribe  => [
      File['/etc/grid-security/hostcert.pem'],
      File['/etc/grid-security/hostkey.pem'],
    ],
  }

  service { 'gratia-probes-cron':
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }

}
