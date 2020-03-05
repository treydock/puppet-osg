# @summary Manage OSG client
#
# @param with_condor
# @param with_condor_ce
# @param manage_firewall
# @param enable_condor_service
# @param enable_condor_ce_service
# @param condor_configs_override
# @param condor_ce_configs_override
#
class osg::client (
  Boolean $with_condor = true,
  Boolean $with_condor_ce = true,
  Boolean $manage_firewall = true,
  Boolean $enable_condor_service = false,
  Boolean $enable_condor_ce_service = false,
  Hash $condor_configs_override = {},
  Hash $condor_ce_configs_override = {},
) inherits osg::params {

  include osg
  include osg::cacerts
  include osg::wn

  $condor_configs_default = {
    'SCHEDD_HOST'       => $osg::condor_schedd_host,
    'COLLECTOR_HOST'    => $osg::condor_collector_host,
    'use_x509userproxy' => 'true', # lint:ignore:quoted_booleans
    'SUBMIT_EXPRS'      => '$(SUBMIT_EXPRS), use_x509userproxy',
  }

  $condor_ce_configs_default = {
    'SCHEDD_HOST'       => $osg::condor_schedd_host,
    'COLLECTOR_HOST'    => $osg::condor_collector_host,
    'use_x509userproxy' => 'true', # lint:ignore:quoted_booleans
    'SUBMIT_EXPRS'      => '$(SUBMIT_EXPRS), use_x509userproxy',
  }

  $condor_configs    = merge($condor_configs_default, $condor_configs_override)
  $condor_ce_configs = merge($condor_ce_configs_default, $condor_ce_configs_override)

  anchor { 'osg::client::start': }
  -> Class['osg']
  -> Class['osg::cacerts']
  -> class { 'osg::client::install': }
  -> class { 'osg::client::config': }
  -> class { 'osg::client::service': }
  -> anchor { 'osg::client::end': }

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
