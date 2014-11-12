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

  $sudo_srm_cmd = is_string($sudo_srm_commands) ? {
    true  => $sudo_srm_commands,
    false => join($sudo_srm_commands, ',')
  }

  $sudo_srm_usr = is_string($sudo_srm_runas) ? {
    true  => $sudo_srm_runas,
    false => join($sudo_srm_runas, ',')
  }

  include osg
  include osg::cacerts
  include osg::gums::client

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
