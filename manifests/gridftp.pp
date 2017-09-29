# Class: osg::gridftp: See README.md for documentation.
class osg::gridftp (
  Boolean $manage_hostcert = true,
  Optional[String] $hostcert_source = undef,
  Optional[String] $hostkey_source = undef,
  Boolean $manage_firewall = true,
  Boolean $standalone = true,
) inherits osg::params {

  include osg
  include osg::cacerts
  include osg::auth

  if $standalone {
    anchor { 'osg::gridftp::start': }
    -> Class['osg']
    -> Class['osg::cacerts']
    -> class { 'osg::gridftp::install': }
    -> Class['osg::auth']
    -> class { 'osg::gridftp::config': }
    ~> class { 'osg::gridftp::service': }
    -> anchor { 'osg::gridftp::end': }
  } else {
    anchor { 'osg::gridftp::start': }
    -> class { 'osg::gridftp::install': }
    -> Class['osg::auth']
    -> class { 'osg::gridftp::config': }
    ~> class { 'osg::gridftp::service': }
    -> anchor { 'osg::gridftp::end': }
  }

  if $manage_firewall {
    firewall { '100 allow GridFTP':
      action => 'accept',
      dport  => '2811',
      proto  => 'tcp',
    }
    firewall { '100 allow GLOBUS_TCP_PORT_RANGE':
      action => 'accept',
      dport  => "${osg::globus_tcp_port_range_min}-${osg::globus_tcp_port_range_max}",
      proto  => 'tcp',
    }

    firewall { '100 allow GLOBUS_TCP_SOURCE_RANGE':
      action => 'accept',
      sport  => "${osg::globus_tcp_source_range_min}-${osg::globus_tcp_source_range_max}",
      proto  => 'tcp',
    }
  }

}
