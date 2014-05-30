# == Class: osg::ce::service
#
class osg::ce::service {

  include osg::ce

  service { 'globus-gatekeeper':
    ensure      => 'running',
    enable      => true,
    hasstatus   => true,
    hasrestart  => true,
  }->
  service { 'globus-gridftp-server':
    ensure      => 'running',
    enable      => true,
    hasstatus   => true,
    hasrestart  => true,
  }->
  service { $osg::ce::cemon_service_name:
    ensure      => 'running',
    enable      => true,
    hasstatus   => true,
    hasrestart  => true,
  }->
  service { 'gratia-probes-cron':
    ensure      => 'running',
    enable      => true,
    hasstatus   => true,
    hasrestart  => true,
  }->
  service { 'osg-cleanup-cron':
    ensure      => 'running',
    enable      => true,
    hasstatus   => true,
    hasrestart  => true,
  }

}
