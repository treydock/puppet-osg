# == Class: osg::ce::service
#
class osg::ce::service {

  include osg::ce

  if $osg::ce::gram_gateway_enabled {
    service { 'globus-gatekeeper':
      ensure     => 'running',
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
      before     => Service[$osg::ce::cemon_service_name]
    }
  }

  if $osg::ce::htcondor_gateway_enabled {
    service { 'condor-ce':
      ensure     => 'running',
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
      before     => Service[$osg::ce::cemon_service_name]
    }
  }

  service { $osg::ce::cemon_service_name:
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
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
