# Private class: See README.md.
class osg::gums::config {

  file { '/etc/grid-security/http':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { '/etc/grid-security/http/httpcert.pem':
    ensure  => 'file',
    owner   => 'tomcat',
    group   => 'tomcat',
    mode    => '0444',
    source  => $osg::gums::_httpcert_source,
    require => File['/etc/grid-security/http'],
  }

  file { '/etc/grid-security/http/httpkey.pem':
    ensure  => 'file',
    owner   => 'tomcat',
    group   => 'tomcat',
    mode    => '0400',
    source  => $osg::gums::_httpkey_source,
    require => File['/etc/grid-security/http'],
  }

  # File show_diff only in Puppet >= 3.2.0
  if versioncmp($::puppetversion, '3.2.0') >= 0 {
    File <| title == '/etc/grid-security/http/httpcert.pem' |> { show_diff => false }
    File <| title == '/etc/grid-security/http/httpkey.pem' |> { show_diff => false }
  }

  file { '/etc/gums/gums.config':
    ensure  => 'file',
    content => undef,
    owner   => 'tomcat',
    group   => 'tomcat',
    mode    => '0600',
    replace => false,
  }

  augeas { 'gums.config-persistenceFactories':
    lens    => 'Xml.lns',
    incl    => '/etc/gums/gums.config',
    changes => [
      "set gums/persistenceFactories/hibernatePersistenceFactory/#attribute/hibernate.connection.username \"${osg::gums::db_username}\"",
      "set gums/persistenceFactories/hibernatePersistenceFactory/#attribute/hibernate.connection.url \"${osg::gums::db_url}\"",
      "set gums/persistenceFactories/hibernatePersistenceFactory/#attribute/hibernate.connection.password \"${osg::gums::db_password}\"",
    ],
  }

  if $osg::gums::manage_tomcat {
    file_line { 'catalina-prefix':
      path  => "${osg::gums::tomcat_conf_dir}/logging.properties",
      line  => '1catalina.org.apache.juli.FileHandler.prefix = catalina',
      match => '^1catalina.org.apache.juli.FileHandler.prefix.*',
    }
    file_line { 'catalina-rotatable':
      path  => "${osg::gums::tomcat_conf_dir}/logging.properties",
      line  => '1catalina.org.apache.juli.FileHandler.rotatable = false',
      match => '^1catalina.org.apache.juli.FileHandler.rotatable.*',
      after => '^1catalina.org.apache.juli.FileHandler.prefix.*',
    }
  }

  if $osg::gums::manage_mysql {
    include ::mysql::server

    file { '/usr/lib/gums/sql/setupDatabase-puppet.mysql':
      ensure  => 'file',
      content => template('osg/gums/setupDatabase.mysql.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      before  => Mysql::Db[$osg::gums::db_name],
    }

    mysql::db { $osg::gums::db_name:
      user     => $osg::gums::db_username,
      password => $osg::gums::db_password,
      host     => $osg::gums::db_hostname,
      grant    => ['ALL'],
      sql      => '/usr/lib/gums/sql/setupDatabase-puppet.mysql',
    }
  }

  if $osg::gums::manage_logrotate {
    logrotate::rule { 'tomcat-catalina-logs':
      path         => "${osg::gums::tomcat_log_dir}/catalina.log",
      copytruncate => true,
      rotate_every => 'week',
      rotate       => '52',
      compress     => true,
      missingok    => true,
      create       => true,
      create_mode  => '0644',
      create_owner => 'tomcat',
      create_group => 'tomcat',
    }
  }

}
