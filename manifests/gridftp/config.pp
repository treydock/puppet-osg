# @summary Manage GridFTP configs
# @api private
class osg::gridftp::config {

  $globus_tcp_port_range_min    = $osg::globus_tcp_port_range_min
  $globus_tcp_port_range_max    = $osg::globus_tcp_port_range_max
  $globus_tcp_source_range_min  = $osg::globus_tcp_source_range_min
  $globus_tcp_source_range_max  = $osg::globus_tcp_source_range_max

  file { '/etc/sysconfig/globus-gridftp-server':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('osg/gridftp/globus-gridftp-server.erb'),
  }

  if $osg::gridftp::manage_hostcert {
    file { '/etc/grid-security/hostcert.pem':
      ensure    => 'file',
      owner     => 'root',
      group     => 'root',
      mode      => '0444',
      source    => $osg::gridftp::hostcert_source,
      show_diff => false
    }

    file { '/etc/grid-security/hostkey.pem':
      ensure    => 'file',
      owner     => 'root',
      group     => 'root',
      mode      => '0400',
      source    => $osg::gridftp::hostkey_source,
      show_diff => false
    }
  }

}
