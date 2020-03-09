# @summary Manage OSG client
#
# @param with_condor
#   Include Condor support
# @param with_condor_ce
#   Include Condor CE support
# @param condor_lowport
#   Condor lowport
# @param condor_highport
#   Condor highport
# @param condor_schedd_host
#   Condor schedd host
# @param condor_collector_host
#   Condor collector host
# @param manage_firewall
#   Manage the firewall rules
# @param enable_condor_service
#   Enable Condor service
# @param enable_condor_ce_service
#   Enable Condor CE service
# @param condor_configs_override
#   Config overrides for Condor
# @param condor_ce_configs_override
#   Config overrides for Condor CE
#
class osg::client (
  Boolean $with_condor = true,
  Boolean $with_condor_ce = true,
  Integer[0, 65535] $condor_lowport = 40000,
  Integer[0, 65535] $condor_highport = 41999,
  Optional[String] $condor_schedd_host = undef,
  Optional[String] $condor_collector_host = undef,
  Boolean $manage_firewall = true,
  Boolean $enable_condor_service = false,
  Boolean $enable_condor_ce_service = false,
  Hash $condor_configs_override = {},
  Hash $condor_ce_configs_override = {},
) {

  include osg
  include osg::cacerts
  include osg::wn

  $condor_configs_default = {
    'SCHEDD_HOST'       => $condor_schedd_host,
    'COLLECTOR_HOST'    => $condor_collector_host,
    'use_x509userproxy' => 'true', # lint:ignore:quoted_booleans
    'SUBMIT_EXPRS'      => '$(SUBMIT_EXPRS), use_x509userproxy',
  }

  $condor_ce_configs_default = {
    'SCHEDD_HOST'       => $condor_schedd_host,
    'COLLECTOR_HOST'    => $condor_collector_host,
    'use_x509userproxy' => 'true', # lint:ignore:quoted_booleans
    'SUBMIT_EXPRS'      => '$(SUBMIT_EXPRS), use_x509userproxy',
  }

  $condor_configs    = merge($condor_configs_default, $condor_configs_override)
  $condor_ce_configs = merge($condor_ce_configs_default, $condor_ce_configs_override)

  contain osg::client::install
  contain osg::client::config
  contain osg::client::service

  Class['osg']
  -> Class['osg::cacerts']
  -> Class['osg::client::install']
  -> Class['osg::client::config']
  -> Class['osg::client::service']

  Class['osg::wn'] -> Class['osg::client::install']

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
