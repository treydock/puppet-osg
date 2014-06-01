# == Class: osg::gridftp
#
class osg::gridftp (
  $cacerts_package_name = 'empty-ca-certs',
  $cacerts_package_ensure = 'installed',
  $globus_tcp_port_range_min = '40000',
  $globus_tcp_port_range_max = '41999',
  $globus_tcp_source_range_min = '40000',
  $globus_tcp_source_range_max = '41999',
  $hostcert_source = 'UNSET',
  $hostkey_source = 'UNSET',
  $manage_firewall = true,
) inherits osg::params {

  validate_bool($manage_firewall)

  include osg

  class { 'osg::cacerts':
    package_name    => $cacerts_package_name,
    package_ensure  => $cacerts_package_ensure,
  }

  include osg::gums::client
  include osg::gridftp::install
  include osg::gridftp::config
  include osg::gridftp::service

  anchor { 'osg::gridftp::start': }
  anchor { 'osg::gridftp::end': }

  Anchor['osg::gridftp::start']->
  Class['osg::repo']->
  Class['osg::cacerts']->
  Class['osg::gridftp::install']->
  Class['osg::gridftp::config']->
  Class['osg::gums::client']->
  Class['osg::gridftp::service']->
  Anchor['osg::gridftp::end']

  if $manage_firewall {
    firewall { '100 allow GridFTP':
      action  => 'accept',
      dport   => '2811',
      proto   => 'tcp',
    }
    firewall { '100 allow GLOBUS_TCP_PORT_RANGE':
      action  => 'accept',
      dport   => "${globus_tcp_port_range_min}-${globus_tcp_port_range_max}",
      proto   => 'tcp',
    }

    firewall { '100 allow GLOBUS_TCP_SOURCE_RANGE':
      action  => 'accept',
      sport   => "${globus_tcp_source_range_min}-${globus_tcp_source_range_max}",
      proto   => 'tcp',
    }
  }

}
