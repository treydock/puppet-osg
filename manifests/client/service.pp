# == Class: osg::client::service
#
class osg::client::service {

  include osg::client

  if $osg::client::with_condor {
    service { 'condor':
      ensure      => 'running',
      enable      => true,
      hasstatus   => true,
      hasrestart  => true,
    }
  }

}
