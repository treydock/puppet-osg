# == Class: osg::gridftp::service
#
class osg::gridftp::service {

  service { 'globus-gridftp-server':
    ensure     => 'running',
    enable     => true,
    hasstatus  => true, # TODO: status does not work!
    hasrestart => true,
  }

}
