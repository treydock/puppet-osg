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

  service { 'condor-ce':
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    subscribe  => $_ce_service_subscribe,
  }

  if $osg::osg_release == '3.3' {
    service { $osg::ce::cemon_service_name:
      ensure     => 'running',
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
      subscribe  => $_info_service_subscribe,
    }
  }
  service { 'gratia-probes-cron':
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }

  if $osg::osg_release == '3.3' {
    service { 'osg-cleanup-cron':
      ensure     => $osg::ce::enable_cleanup ? { #lint:ignore:selector_inside_resource
        true  => 'running',
        false => 'stopped',
      },
      enable     => $osg::ce::enable_cleanup,
      hasstatus  => true,
      hasrestart => true,
    }
  }

}
