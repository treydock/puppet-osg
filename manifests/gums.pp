# Class: osg::gums: See README.md for documentation.
class osg::gums (
  $httpcert_source    = 'UNSET',
  $httpkey_source     = 'UNSET',
  $db_name            = 'GUMS_1_3',
  $db_username        = 'gums',
  $db_password        = 'changeme',
  $db_hostname        = 'localhost',
  $db_port            = '3306',
  $port               = '8443',
  $manage_firewall    = true,
  $firewall_interface = 'eth0',
  $manage_tomcat      = true,
  $tomcat_conf_dir    = $osg::params::tomcat_conf_dir,
  $tomcat_base_dir    = $osg::params::tomcat_base_dir,
  $tomcat_log_dir     = $osg::params::tomcat_log_dir,
  $tomcat_service     = $osg::params::tomcat_service,
  $manage_mysql       = true,
  $manage_logrotate   = true,
) inherits osg::params {

  validate_bool($manage_firewall)
  validate_bool($manage_tomcat)
  validate_bool($manage_mysql)

  include osg
  include osg::cacerts

  if $::osg::osg_release == '3.4' {
    fail('OSG 3.4 does not support GUMS')
  }

  $_httpcert_source = $httpcert_source ? {
    'UNSET' => undef,
    default => $httpcert_source,
  }

  $_httpkey_source = $httpkey_source ? {
    'UNSET' => undef,
    default => $httpkey_source,
  }

  $db_url = "jdbc:mysql://${osg::gums::db_hostname}:${osg::gums::db_port}/${osg::gums::db_name}"

  anchor { 'osg::gums::start': }
  -> Class['osg']
  -> Class['osg::cacerts']
  -> class { 'osg::gums::install': }
  -> class { 'osg::gums::config': }
  ~> class { 'osg::gums::service': }
  -> anchor { 'osg::gums::end': }

  if $manage_firewall {
    firewall { '100 allow GUMS access':
      port    => $port,
      proto   => tcp,
      iniface => $firewall_interface,
      action  => accept,
    }
  }
}
