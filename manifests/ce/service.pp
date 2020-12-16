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
    ensure     => $osg::ce::gratia_probes_cron_service_ensure,
    enable     => $osg::ce::gratia_probes_cron_service_enable,
    hasstatus  => true,
    hasrestart => true,
  }

}
