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

  file { '/etc/gums/gums.config':
    ensure  => 'file',
    content => undef,
    owner   => 'tomcat',
    group   => 'tomcat',
    mode    => '0600',
    replace => false,
  }

  if $osg::gums::manage_tomcat {
    file { '/etc/tomcat6/server.xml':
      ensure  => 'file',
      content => template('osg/gums/server.xml.erb'),
      owner   => 'tomcat',
      group   => 'root',
      mode    => '0664',
    }

    file { '/etc/tomcat6/log4j-trustmanager.properties':
      ensure => 'file',
      source => 'file:///var/lib/trustmanager-tomcat/log4j-trustmanager.properties',
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
    }

    file { '/usr/share/tomcat6/lib/bcprov.jar':
      ensure => 'link',
      target => '/usr/share/java/bcprov.jar',
    }

    file { '/usr/share/tomcat6/lib/trustmanager.jar':
      ensure => 'link',
      target => '/usr/share/java/trustmanager.jar',
    }

    file { '/usr/share/tomcat6/lib/trustmanager-tomcat.jar':
      ensure => 'link',
      target => '/usr/share/java/trustmanager-tomcat.jar',
    }

    file { '/usr/share/tomcat6/lib/commons-logging.jar':
      ensure => 'link',
      target => '/usr/share/java/commons-logging.jar',
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

}
