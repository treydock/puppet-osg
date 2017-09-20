# Private class: See README.md.
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
      ensure => 'file',
      owner  => 'root',
      group  => 'root',
      mode   => '0444',
      source => $osg::gridftp::_hostcert_source,
    }

    file { '/etc/grid-security/hostkey.pem':
      ensure => 'file',
      owner  => 'root',
      group  => 'root',
      mode   => '0400',
      source => $osg::gridftp::_hostkey_source,
    }

    # File show_diff only in Puppet >= 3.2.0
    if versioncmp($::puppetversion, '3.2.0') >= 0 {
      File <| title == '/etc/grid-security/hostcert.pem' |> { show_diff => false }
      File <| title == '/etc/grid-security/hostkey.pem' |> { show_diff => false }
    }
  }

  if $::osg::auth_type == 'gums' {
    file { '/etc/grid-security/grid-mapfile':
      ensure => 'file',
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
    }
  }

}
