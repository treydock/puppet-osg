# == Class: osg::gridftp
#
class osg::gridftp (
  $hostcert_source = 'UNSET',
  $hostkey_source = 'UNSET',
  $manage_firewall = true,
  $standalone = true,
) inherits osg::params {

  validate_bool($manage_firewall)

  include osg
  include osg::cacerts
  include osg::gums::client

  if $standalone {
    anchor { 'osg::gridftp::start': }->
    Class['osg']->
    Class['osg::cacerts']->
    class { 'osg::gridftp::install': }->
    Class['osg::gums::client']->
    class { 'osg::gridftp::config': }~>
    class { 'osg::gridftp::service': }->
    anchor { 'osg::gridftp::end': }
  } else {
    anchor { 'osg::gridftp::start': }->
    class { 'osg::gridftp::install': }->
    Class['osg::gums::client']->
    class { 'osg::gridftp::config': }~>
    class { 'osg::gridftp::service': }->
    anchor { 'osg::gridftp::end': }
  }

  if $manage_firewall {
    firewall { '100 allow GridFTP':
      action  => 'accept',
      dport   => '2811',
      proto   => 'tcp',
    }
    firewall { '100 allow GLOBUS_TCP_PORT_RANGE':
      action  => 'accept',
      dport   => "${osg::globus_tcp_port_range_min}-${osg::globus_tcp_port_range_max}",
      proto   => 'tcp',
    }

    firewall { '100 allow GLOBUS_TCP_SOURCE_RANGE':
      action  => 'accept',
      sport   => "${osg::globus_tcp_source_range_min}-${osg::globus_tcp_source_range_max}",
      proto   => 'tcp',
    }
  }

}
