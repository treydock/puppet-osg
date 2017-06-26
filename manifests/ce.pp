# Class: osg::ce: See README.md for documentation.
class osg::ce (
  $gram_gateway_enabled       = false,
  $htcondor_gateway_enabled   = true,
  $site_info_group            = 'OSG',
  $site_info_host_name        = $::fqdn,
  $site_info_resource         = 'UNAVAILABLE',
  $site_info_resource_group   = 'UNAVAILABLE',
  $site_info_sponsor          = 'UNAVAILABLE',
  $site_info_site_policy      = 'UNAVAILABLE',
  $site_info_contact          = 'UNAVAILABLE',
  $site_info_email            = 'UNAVAILABLE',
  $site_info_city             = 'UNAVAILABLE',
  $site_info_country          = 'UNAVAILABLE',
  $site_info_longitude        = 'UNAVAILABLE',
  $site_info_latitude         = 'UNAVAILABLE',
  $batch_system               = 'torque',
  $batch_system_prefix        = '/usr',
  $pbs_server                 = 'UNAVAILABLE',
  $enable_cleanup             = true,
  $manage_hostcert            = true,
  $hostcert_source            = 'UNSET',
  $hostkey_source             = 'UNSET',
  $httpcert_source            = 'UNSET',
  $httpkey_source             = 'UNSET',
  $htcondor_ce_port           = '9619',
  $htcondor_ce_shared_port    = '9620',
  $manage_firewall            = true,
  $osg_local_site_settings    = {},
  $osg_gip_configs            = {},
  $tomcat_package             = $osg::params::tomcat_package,
  $manage_users               = true,
  $condor_uid                 = undef,
  $condor_gid                 = undef,
  $gratia_uid                 = undef,
  $gratia_gid                 = undef,
  $condor_ce_config_content   = undef,
  $condor_ce_config_source    = undef,
) inherits osg::params {

  validate_bool($gram_gateway_enabled)
  validate_bool($htcondor_gateway_enabled)
  validate_bool($manage_hostcert)
  validate_bool($manage_firewall)
  validate_hash($osg_local_site_settings)
  validate_hash($osg_gip_configs)

  include osg
  include osg::cacerts
  include osg::tomcat::user

  $cemon_service_name = 'osg-info-services'

  case $batch_system {
    /torque|pbs/: {
      $batch_system_package_name  = 'empty-torque'
      $ce_package_name            = 'osg-ce-pbs'
      $batch_ini_section          = 'PBS'
      $location_name              = 'pbs_location'
      $job_contact                = 'jobmanager-pbs'
      $util_contact               = 'jobmanager'
      $batch_settings             = {
        'PBS/pbs_server' => { 'value' => $pbs_server }
      }
    }
    'slurm': {
      $batch_system_package_name  = 'empty-slurm'
      $ce_package_name            = 'osg-ce-slurm'
      $batch_ini_section          = 'SLURM'
      $location_name              = 'slurm_location'
      $job_contact                = 'jobmanager-pbs'
      $util_contact               = 'jobmanager'
      $batch_settings             = {}
    }
    default: {
      fail('osg::ce: batch_system must be either torque, pbs or slurm')
    }
  }

  $_httpcert_source = $httpcert_source ? {
    'UNSET' => undef,
    default => $httpcert_source,
  }

  $_httpkey_source = $httpkey_source ? {
    'UNSET' => undef,
    default => $httpkey_source,
  }

  class { 'osg::gridftp':
    manage_hostcert => $manage_hostcert,
    hostcert_source => $hostcert_source,
    hostkey_source  => $hostkey_source,
    manage_firewall => $manage_firewall,
    standalone      => false,
  }

  anchor { 'osg::ce::start': }
  -> Class['osg']
  -> Class['osg::cacerts']
  -> Class['osg::tomcat::user']
  -> class { 'osg::ce::users': }
  -> class { 'osg::ce::install': }
  -> Class['osg::gridftp']
  -> class { 'osg::ce::config': }
  -> class { 'osg::ce::service': }
  -> anchor { 'osg::ce::end': }

  if $manage_firewall {
    if $gram_gateway_enabled {
      firewall { '100 allow GRAM':
        ensure => 'present',
        action => 'accept',
        dport  => '2119',
        proto  => 'tcp',
      }
    }

    if $htcondor_gateway_enabled {
      firewall { '100 allow HTCondorCE':
        ensure => 'present',
        action => 'accept',
        dport  => $htcondor_ce_port,
        proto  => 'tcp',
      }
      firewall { '100 allow HTCondorCE shared_port':
        ensure => 'present',
        action => 'accept',
        dport  => $htcondor_ce_shared_port,
        proto  => 'tcp',
      }
    }
  }
}
