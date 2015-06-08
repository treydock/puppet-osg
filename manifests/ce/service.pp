# Private class: See README.md.
class osg::ce::service {

  $_ce_service_subscribe = [
    File['/etc/grid-security/hostcert.pem'],
    File['/etc/grid-security/hostkey.pem'],
  ]

  $_info_service_subscribe = [
    File['/etc/grid-security/http/httpcert.pem'],
    File['/etc/grid-security/http/httpkey.pem'],
  ]

  if $osg::ce::gram_gateway_enabled {
    service { 'globus-gatekeeper':
      ensure     => 'running',
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
      subscribe  => $_ce_service_subscribe,
      before     => Service[$osg::ce::cemon_service_name]
    }
  }

  if $osg::ce::htcondor_gateway_enabled {
    service { 'condor-ce':
      ensure     => 'running',
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
      subscribe  => $_ce_service_subscribe,
      before     => Service[$osg::ce::cemon_service_name]
    }
  }

  service { $osg::ce::cemon_service_name:
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    subscribe  => $_info_service_subscribe,
  }->
  service { 'gratia-probes-cron':
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }->
  service { 'osg-cleanup-cron':
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }

}
