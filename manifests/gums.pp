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
# [*manage_firewall*]
#   Boolean value to set if this module should manage the
#   system's firewall for GUMS.
#   Default: true
#
# [*firewall_port*]
#   Sets the iptables port used by GUMS.
#   Default: 8443
#
# [*manage_tomcat*]
#   Determines if the osg::tomcat module is included.
#   Set to false to use an external tomcat module
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
  $db_name          = 'GUMS_1_3',
  $db_username      = 'gums',
  $db_password      = 'UNSET',
  $db_hostname      = 'localhost',
  $db_port          = '3306',
  $manage_firewall  = true,
  $firewall_port    = '8443',
  $manage_tomcat    = true
) inherits osg {

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

  Class['mysql::server'] -> Class['osg::gums']
  Class['osg::repo'] -> Class['osg::cacerts'] -> Class['osg::gums']
  if $manage_firewall_real { Class['firewall'] -> Class['osg::gums'] }
  if $manage_tomcat_real { Class['osg::gums'] -> Class['osg::tomcat'] }

  include osg::repo
  include osg::cacerts
  if $manage_firewall_real { include firewall }
  if $manage_tomcat_real { include osg::tomcat }

  package { 'osg-gums':
    ensure  => installed,
    require => Yumrepo['osg'],
  }

  file { '/root/gums-post-install.sh':
    ensure  => present,
    content => template('osg/gums/gums-post-install.sh.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
  }

  if $manage_firewall_real {
    firewall { '100 allow GUMS access':
      port    => $firewall_port,
      proto   => tcp,
      action  => accept,
    }
  }
}
