# @summary Manage OSG CE
#
# @param storage_grid_dir
#   osg-configure Storage/grid_dir
# @param storage_app_dir
#   osg-configure Storage/app_dir
# @param storage_data_dir
#   osg-configure Storage/data_dir
# @param storage_worker_node_temp
#   osg-configure Storage/worker_node_temp
# @param storage_site_read
#   osg-configure Storage/site_read
# @param storage_site_write
#   osg-configure Storage/site_write
# @param batch_system
#   Batch system used to submit jobs
# @param batch_system_prefix
#   Prefix of where batch system commands are installed
# @param pbs_server
#   PBS server address when `batch_system` is `torque` or `pbs`
# @param manage_hostcert
#   Boolean that determines if hostcert is managed
# @param hostcert_source
#   The source of the hostcert
# @param hostkey_source
#   The source of the hostkey
# @param htcondor_ce_port
#   HTCondor CE port
# @param htcondor_ce_shared_port
#   HTCondor CE shared port
# @param manage_firewall
#   Boolean taht determines if firewall rules should be managed
# @param osg_local_site_settings
#   Extra configs for osg-configure local site settings
#   Example: `{ 'Local Settings/PATH' => { 'value' => '/opt/singularity/bin:$PATH' } }`
# @param osg_gip_configs
#   Extra configs for osg-configure GIP configs
#   Example: `{ 'Subcluster owens/ram_mb' => { 'value' => 128000 } }`
# @param manage_users
#   Boolean of whether to manage users and groups
# @param condor_uid
#   The UID of condor user
# @param condor_gid
#   The GID of condor group
# @param gratia_uid
#   The UID of gratia user
# @param gratia_gid
#   The GID of gratia group
# @param condor_ce_config_content
#   Content for /etc/condor-ce/config.d/99-local.conf
# @param condor_ce_config_source
#   Source for /etc/condor-ce/config.d/99-local.conf
# @param blahp_local_submit_content
#   Content for blahp local submit attributes
# @param blahp_local_submit_source
#   Source for blahp local submit attributes
# @param include_view
#   Boolean to determine if adding Condor CE View
# @param view_port
#   Port for Condor CE View
#
class osg::ce (
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
) {

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

  include osg::configure::site_info
  contain osg::ce::users
  contain osg::ce::install
  contain osg::ce::config
  contain osg::ce::service

  Class['osg']
  -> Class['osg::cacerts']
  -> Class['osg::ce::users']
  -> Class['osg::ce::install']
  -> Class['osg::gridftp']
  -> Class['osg::configure::site_info']
  -> Class['osg::ce::config']
  -> Class['osg::ce::service']

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
