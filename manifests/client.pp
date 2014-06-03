# == Class: osg::client
#
class osg::client (
  $with_condor = true,
  $manage_firewall = true,
) inherits osg::params {

  validate_bool($with_condor)
  validate_bool($manage_firewall)

  include osg
  include osg::cacerts
  include osg::client::install
  include osg::client::config
  include osg::client::service

  anchor { 'osg::client::start': }
  anchor { 'osg::client::end': }

  Anchor['osg::client::start']->
  Class['osg']->
  Class['osg::cacerts']->
  Class['osg::client::install']->
  Class['osg::client::config']->
  Class['osg::client::service']->
  Anchor['osg::client::end']

  if $manage_firewall {
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
