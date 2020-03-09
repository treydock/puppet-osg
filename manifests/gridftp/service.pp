# @summary Manage GridFTP service
# @api private
class osg::gridftp::service {

  service { 'globus-gridftp-server':
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }

}
