# == Class: osg::client::service
#
class osg::client::service {

  include osg::client

  if $osg::client::with_condor {
    service { 'condor':
      ensure      => $osg::client::condor_service_ensure,
      enable      => $osg::client::condor_service_enable,
      hasstatus   => true,
      hasrestart  => true,
    }

    service { 'condor-ce':
      ensure      => $osg::client::condor_ce_service_ensure,
      enable      => $osg::client::condor_ce_service_enable,
      hasstatus   => true,
      hasrestart  => true,
    }
  }

}
