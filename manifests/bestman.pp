# == Class: osg::bestman
#
class osg::bestman (
  $host_dn                = 'UNSET',
  $hostcert_source        = 'UNSET',
  $hostkey_source         = 'UNSET',
  $bestmancert_source     = 'UNSET',
  $bestmankey_source      = 'UNSET',
  $globus_hostname        = $::fqdn,
  $event_log_count        = 10,
  $event_log_size         = 20971520,
  $manage_firewall        = true,
  $securePort             = '8443',
  $localPathListToBlock   = [],
  $localPathListAllowed   = [],
  $supportedProtocolList  = [],
  $noSudoOnLs             = true,
  $accessFileSysViaGsiftp = false,
  $manage_sudo            = true,
  $sudo_srm_commands      = $osg::params::sudo_srm_commands,
  $sudo_srm_runas         = $osg::params::sudo_srm_runas,
) inherits osg::params {

  validate_bool($manage_firewall)
  validate_bool($manage_sudo)
  validate_array($localPathListToBlock)
  validate_array($localPathListAllowed)
  validate_array($supportedProtocolList)

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

  $gums_host = $osg::gums_host

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

  anchor { 'osg::bestman::start': }->
  Class['osg']->
  Class['osg::cacerts']->
  class { 'osg::bestman::install': }->
  Class['osg::gums::client']->
  class { 'osg::bestman::config': }~>
  class { 'osg::bestman::service': }->
  anchor { 'osg::bestman::end': }

  if $manage_firewall {
    firewall { '100 allow SRMv2 access':
      port   => $securePort,
      proto  => 'tcp',
      action => 'accept',
    }
  }

}
