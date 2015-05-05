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
  $manage_mysql       = true
) inherits osg::params {

  validate_bool($manage_firewall)
  validate_bool($manage_tomcat)
  validate_bool($manage_mysql)

  include osg
  include osg::cacerts

  $_httpcert_source = $httpcert_source ? {
    'UNSET' => undef,
    default => $httpcert_source,
  }

  $_httpkey_source = $httpkey_source ? {
    'UNSET' => undef,
    default => $httpkey_source,
  }

  anchor { 'osg::gums::start': }->
  Class['osg']->
  Class['osg::cacerts']->
  class { 'osg::gums::install': }->
  class { 'osg::gums::config': }~>
  class { 'osg::gums::service': }->
  anchor { 'osg::gums::end': }

  if $manage_firewall {
    firewall { '100 allow GUMS access':
      port    => $port,
      proto   => tcp,
      iniface => $firewall_interface,
      action  => accept,
    }
  }
}
