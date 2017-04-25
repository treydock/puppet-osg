# Class: osg::bestman: See README.md for documentation.
class osg::bestman (
  $host_dn                = 'UNSET',
  $manage_hostcert        = true,
  $hostcert_source        = 'UNSET',
  $hostkey_source         = 'UNSET',
  $bestmancert_source     = 'UNSET',
  $bestmankey_source      = 'UNSET',
  $globus_hostname        = $::fqdn,
  $event_log_count        = 10,
  $event_log_size         = 20971520,
  $manage_firewall        = true,
  $secure_port             = '8443',
  $local_path_list_to_block   = [],
  $local_path_list_allowed   = [],
  $supported_protocol_list  = [],
  $no_sudo_on_ls             = true,
  $access_file_sys_via_gsiftp = false,
  $manage_sudo            = true,
  $sudo_srm_commands      = $osg::params::sudo_srm_commands,
  $sudo_srm_runas         = $osg::params::sudo_srm_runas,
  $max_java_heap          = 1024,
) inherits osg::params {

  validate_bool($manage_hostcert)
  validate_bool($manage_firewall)
  validate_bool($manage_sudo)
  validate_array($local_path_list_to_block)
  validate_array($local_path_list_allowed)
  validate_array($supported_protocol_list)

  include osg
  include osg::cacerts
  include osg::gums::client

  $sudo_srm_cmd = is_string($sudo_srm_commands) ? {
    true  => $sudo_srm_commands,
    false => join($sudo_srm_commands, ',')
  }

  $sudo_srm_usr = is_string($sudo_srm_runas) ? {
    true  => $sudo_srm_runas,
    false => join($sudo_srm_runas, ',')
  }

  $gums_host = $osg::_gums_host

  $_hostcert_source = $hostcert_source ? {
    'UNSET' => undef,
    default => $hostcert_source,
  }

  $_hostkey_source = $hostkey_source ? {
    'UNSET' => undef,
    default => $hostkey_source,
  }

  $_bestmancert_source = $bestmancert_source ? {
    'UNSET' => undef,
    default => $bestmancert_source,
  }

  $_bestmankey_source = $bestmankey_source ? {
    'UNSET' => undef,
    default => $bestmankey_source,
  }

  $_host_dn = $host_dn ? {
    'UNSET' => "/DC=com/DC=DigiCert-Grid/O=Open Science Grid/OU=Services/CN=${::fqdn}",
    default => $host_dn,
  }

  anchor { 'osg::bestman::start': }
  -> Class['osg']
  -> Class['osg::cacerts']
  -> class { 'osg::bestman::install': }
  -> Class['osg::gums::client']
  -> class { 'osg::bestman::config': }
  ~> class { 'osg::bestman::service': }
  -> anchor { 'osg::bestman::end': }

  if $manage_firewall {
    firewall { '100 allow SRMv2 access':
      port   => $secure_port,
      proto  => 'tcp',
      action => 'accept',
    }
  }

  if $osg::enable_exported_resources {
    @@osg_local_site_settings { 'Storage/se_available':
      value => true,
      tag   => $osg::exported_resources_export_tag,
    }

    $_default_se = pick($osg::storage_default_se, $::fqdn)
    @@osg_local_site_settings { 'Storage/default_se':
      value => $_default_se,
      tag   => $osg::exported_resources_export_tag,
    }

    @@osg_local_site_settings { 'Storage/grid_dir':
      value => $osg::storage_grid_dir,
      tag   => $osg::exported_resources_export_tag,
    }

    @@osg_local_site_settings { 'Storage/app_dir':
      value => $osg::storage_app_dir,
      tag   => $osg::exported_resources_export_tag,
    }

    @@osg_local_site_settings { 'Storage/data_dir':
      value => $osg::storage_data_dir,
      tag   => $osg::exported_resources_export_tag,
    }

    @@osg_local_site_settings { 'Storage/worker_node_temp':
      value => $osg::storage_worker_node_temp,
      tag   => $osg::exported_resources_export_tag,
    }

    @@osg_local_site_settings { 'Storage/site_read':
      value => $osg::storage_site_read,
      tag   => $osg::exported_resources_export_tag,
    }

    @@osg_local_site_settings { 'Storage/site_write':
      value => $osg::storage_site_write,
      tag   => $osg::exported_resources_export_tag,
    }
  }

}
