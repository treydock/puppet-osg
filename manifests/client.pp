# == Class: osg::client
#
class osg::client (
  $with_condor                = true,
  $with_condor_ce             = true,
  $manage_firewall            = true,
  $enable_condor_service      = false,
  $enable_condor_ce_service   = false,
  $condor_configs_override    = {},
  $condor_ce_configs_override = {},
) inherits osg::params {

  validate_bool($with_condor, $with_condor_ce, $manage_firewall)
  validate_bool($enable_condor_service, $enable_condor_ce_service)
  validate_hash($condor_configs_override, $condor_ce_configs_override)

  include osg
  include osg::cacerts

  $condor_configs_default = {
    'SCHEDD_HOST'       => $osg::condor_schedd_host,
    'COLLECTOR_HOST'    => $osg::condor_collector_host,
    'use_x509userproxy' => 'true',
    'SUBMIT_EXPRS'      => '$(SUBMIT_EXPRS), use_x509userproxy',
  }

  $condor_ce_configs_default = {
    'SCHEDD_HOST'       => $osg::condor_schedd_host,
    'COLLECTOR_HOST'    => $osg::condor_collector_host,
    'use_x509userproxy' => 'true',
    'SUBMIT_EXPRS'      => '$(SUBMIT_EXPRS), use_x509userproxy',
  }

  $condor_configs    = merge($condor_configs_default, $condor_configs_override)
  $condor_ce_configs = merge($condor_ce_configs_default, $condor_ce_configs_override)

  anchor { 'osg::client::start': }->
  Class['osg']->
  Class['osg::cacerts']->
  class { 'osg::client::install': }->
  class { 'osg::client::config': }->
  class { 'osg::client::service': }->
  anchor { 'osg::client::end': }

  if $manage_firewall {
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
