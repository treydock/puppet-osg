# @summary Manage OSG CE
#
# @param site_info_group
# @param site_info_host_name
# @param site_info_resource
# @param site_info_resource_group
# @param site_info_sponsor
# @param site_info_site_policy
# @param site_info_contact
# @param site_info_email
# @param site_info_city
# @param site_info_country
# @param site_info_longitude
# @param site_info_latitude
# @param storage_grid_dir
# @param storage_app_dir
# @param storage_data_dir
# @param storage_worker_node_temp
# @param storage_site_read
# @param storage_site_write
# @param batch_system
# @param batch_system_prefix
# @param pbs_server
# @param manage_hostcert
# @param hostcert_source
# @param hostkey_source
# @param htcondor_ce_port
# @param htcondor_ce_shared_port
# @param manage_firewall
# @param osg_local_site_settings
# @param osg_gip_configs
# @param manage_users
# @param condor_uid
# @param condor_gid
# @param gratia_uid
# @param gratia_gid
# @param condor_ce_config_content
# @param condor_ce_config_source
# @param blahp_local_submit_content
# @param blahp_local_submit_source
# @param include_view
# @param view_port
#
class osg::ce (
  String $site_info_group = 'OSG',
  String $site_info_host_name = $::fqdn,
  String $site_info_resource = 'UNAVAILABLE',
  String $site_info_resource_group = 'UNAVAILABLE',
  String $site_info_sponsor = 'UNAVAILABLE',
  String $site_info_site_policy = 'UNAVAILABLE',
  String $site_info_contact = 'UNAVAILABLE',
  String $site_info_email = 'UNAVAILABLE',
  String $site_info_city = 'UNAVAILABLE',
  String $site_info_country = 'UNAVAILABLE',
  String $site_info_longitude = 'UNAVAILABLE',
  String $site_info_latitude = 'UNAVAILABLE',
  String $storage_grid_dir = '/etc/osg/wn-client/',
  String $storage_app_dir = 'UNAVAILABLE',
  String $storage_data_dir = 'UNAVAILABLE',
  String $storage_worker_node_temp = 'UNAVAILABLE',
  String $storage_site_read = 'UNAVAILABLE',
  String $storage_site_write = 'UNAVAILABLE',
  Enum['torque', 'pbs', 'slurm'] $batch_system = 'torque',
  String $batch_system_prefix = '/usr',
  String $pbs_server = 'UNAVAILABLE',
  Boolean $manage_hostcert = true,
  Optional[String] $hostcert_source = undef,
  Optional[String] $hostkey_source = undef,
  Integer[0, 65535] $htcondor_ce_port = 9619,
  Integer[0, 65535] $htcondor_ce_shared_port = 9620,
  Boolean $manage_firewall = true,
  Hash $osg_local_site_settings = {},
  Hash $osg_gip_configs = {},
  Boolean $manage_users = true,
  Optional[Integer] $condor_uid = undef,
  Optional[Integer] $condor_gid = undef,
  Optional[Integer] $gratia_uid = undef,
  Optional[Integer] $gratia_gid = undef,
  Optional[String] $condor_ce_config_content = undef,
  Optional[String] $condor_ce_config_source = undef,
  Optional[String] $blahp_local_submit_content = undef,
  Optional[String] $blahp_local_submit_source = undef,
  Boolean $include_view = false,
  Integer[0, 65535] $view_port = 8080,
) inherits osg::params {

  include osg
  include osg::cacerts

  case $batch_system {
    /torque|pbs/: {
      $batch_system_package_name  = undef
      $ce_package_name            = 'osg-ce-pbs'
      $batch_ini_section          = 'PBS'
      $location_name              = 'pbs_location'
      $job_contact                = 'jobmanager-pbs'
      $util_contact               = 'jobmanager'
      $batch_settings             = {
        'PBS/pbs_server' => { 'value' => $pbs_server }
      }
      $gratia_probe_config        = '/etc/gratia/pbs-lsf/ProbeConfig'
      $blahp_submit_attributes    = '/etc/blahp/pbs_local_submit_attributes.sh'
    }
    'slurm': {
      $batch_system_package_name  = 'empty-slurm'
      $ce_package_name            = 'osg-ce-slurm'
      $batch_ini_section          = 'SLURM'
      $location_name              = 'slurm_location'
      $job_contact                = 'jobmanager-pbs'
      $util_contact               = 'jobmanager'
      $batch_settings             = {}
      $gratia_probe_config        = '/etc/gratia/slurm/ProbeConfig'
      $blahp_submit_attributes    = '/etc/blahp/slurm_local_submit_attributes.sh'
    }
    default: {
      fail('osg::ce: batch_system must be either torque, pbs or slurm')
    }
  }

  if $include_view {
    $view_ensure = 'present'
  } else {
    $view_ensure = 'absent'
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
  -> class { 'osg::ce::users': }
  -> class { 'osg::ce::install': }
  -> Class['osg::gridftp']
  -> class { 'osg::ce::config': }
  -> class { 'osg::ce::service': }
  -> anchor { 'osg::ce::end': }

  if $manage_firewall {
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
    firewall { '100 allow HTCondorCE View':
      ensure => $view_ensure,
      action => 'accept',
      dport  => $view_port,
      proto  => 'tcp',
    }
  }

  exec { 'condor_ce_reconfig':
    path        => '/usr/bin:/bin:/usr/sbin:/sbin',
    refreshonly => true,
  }
}
