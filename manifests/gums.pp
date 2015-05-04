# == Class: osg::gums
#
# Installs and configures a GUMS server for use with OSG.
#
# === Parameters
#
# [*db_name*]
#   GUMS MySQL database name.
#   Default:  'GUMS_1_3',
#
# [*db_username*]
#   GUMS MySQL database username.
#   Default:  'gums',
#
# [*db_password*]
#   GUMS MySQL user password.
#   Default:  'UNSET',
#
# [*db_hostname*]
#   GUMS MySQL hostname.
#   Default:  'localhost',
#
# [*db_port*]
#   GUMS MySQL port.
#   Default:  '3306'
#
# [*port*]
#   Port used by the GUMS service.
#   Default: 8443
#
# [*manage_firewall*]
#   Boolean value to set if this module should manage the
#   system's firewall for GUMS.
#   Default: true
#
# [*firewall_interface*]
#   Sets the interface to allow GUMS access through via iptables
#   Default: eth0
#
# [*manage_tomcat*]
#   Determines if the osg::tomcat module is included.
#   Set to false to use an external tomcat module
#   Default: true
#
# [*manage_mysql*]
#   Boolean value that sets if MySQL
#   should be managed for the GUMS service.
#   Default: true
#
# === Examples
#
#  class { 'osg::gums': }
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2013 Trey Dockendorf
#
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
