# == Class: osg::gums::mysql
#
# Configures MySQL for the GUMS service.
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
#   The default is to set the password to the sha1sum of
#   the db_username parameter.
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
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2013 Trey Dockendorf
#
class osg::gums::mysql (
  $db_name          = $osg::gums::db_name,
  $db_username      = $osg::gums::db_username,
  $db_password      = $osg::gums::db_password,
  $db_hostname      = $osg::gums::db_hostname,
  $db_port          = $osg::gums::db_port
) inherits osg::gums {

  $db_password_real = $db_password ? {
    'UNSET'   => sha1($db_username),
    default   => $db_password,
  }

  include mysql::server

  Class['mysql::server'] -> Class['osg::gums::mysql']

  file { '/usr/lib/gums/sql/setupDatabase-puppet.mysql':
    ensure  => present,
    content => template('osg/gums/setupDatabase.mysql.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['osg-gums'],
    before  => Mysql::Db[$db_name],
  }

  mysql::db { $db_name:
    user      => $db_username,
    password  => $db_password_real,
    host      => $db_hostname,
    grant     => ['all'],
    sql       => '/usr/lib/gums/sql/setupDatabase-puppet.mysql',
  }
}
