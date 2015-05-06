# Private class: See README.md.
class osg::gridftp::config {

  $globus_tcp_port_range_min    = $osg::globus_tcp_port_range_min
  $globus_tcp_port_range_max    = $osg::globus_tcp_port_range_max
  $globus_tcp_source_range_min  = $osg::globus_tcp_source_range_min
  $globus_tcp_source_range_max  = $osg::globus_tcp_source_range_max

  $hostcert_source = $osg::gridftp::hostcert_source ? {
    'UNSET' => undef,
    default => $osg::gridftp::hostcert_source,
  }

  $hostkey_source = $osg::gridftp::hostkey_source ? {
    'UNSET' => undef,
    default => $osg::gridftp::hostkey_source,
  }

  file { '/etc/sysconfig/globus-gridftp-server':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('osg/gridftp/globus-gridftp-server.erb'),
  }

  file { '/etc/grid-security/hostcert.pem':
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0444',
    source => $hostcert_source,
  }

  file { '/etc/grid-security/hostkey.pem':
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0400',
    source => $hostkey_source,
  }

  file { '/etc/grid-security/grid-mapfile':
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

}
