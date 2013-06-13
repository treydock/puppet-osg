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
  $db_name            = 'GUMS_1_3',
  $db_username        = 'gums',
  $db_password        = 'UNSET',
  $db_hostname        = 'localhost',
  $db_port            = '3306',
  $port               = '8443',
  $manage_firewall    = true,
  $firewall_interface = 'eth0',
  $manage_tomcat      = true,
  $manage_mysql       = true
) inherits osg::params {

  $db_password_real = $db_password ? {
    'UNSET'   => sha1($db_username),
    default   => $db_password,
  }

  $manage_firewall_real = is_string($manage_firewall) ? {
    true  => str2bool($manage_firewall),
    false => $manage_firewall,
  }
  validate_bool($manage_firewall_real)

  $manage_tomcat_real = is_string($manage_tomcat) ? {
    true  => str2bool($manage_tomcat),
    false => $manage_tomcat,
  }
  validate_bool($manage_tomcat_real)

  $manage_mysql_real = is_string($manage_mysql) ? {
    true  => str2bool($manage_mysql),
    false => $manage_mysql,
  }
  validate_bool($manage_mysql_real)

  Class['osg::repo'] -> Class['osg::cacerts'] -> Class['osg::gums']
  Class['osg::gums'] -> Class['osg::gums::configure']
  if $manage_firewall_real { Class['firewall'] -> Class['osg::gums'] }
  if $manage_tomcat_real { Class['osg::gums'] -> Class['osg::tomcat'] }

  include osg::repo
  include osg::cacerts
  include osg::gums::configure
  if $manage_firewall_real { include firewall }
  if $manage_tomcat_real { include osg::tomcat }
  if $manage_mysql_real { include osg::gums::mysql }

  package { 'osg-gums':
    ensure  => installed,
    require => Yumrepo['osg'],
  }

  file { '/etc/gums/gums.config':
    ensure  => present,
    content => undef,
    owner   => 'tomcat',
    group   => 'tomcat',
    mode    => '0600',
    replace => false,
    require => Package['osg-gums'],
  }

  if $manage_firewall_real {
    firewall { '100 allow GUMS access':
      port    => $port,
      proto   => tcp,
      iniface => $firewall_interface,
      action  => accept,
    }
  }
}
