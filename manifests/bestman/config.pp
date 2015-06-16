# Private class: See README.md.
class osg::bestman::config {

  if $osg::bestman::manage_sudo {
    sudo::conf { 'bestman':
      priority => 10,
      content  => template('osg/bestman/bestman.sudo.erb'),
    }
  }

  if $osg::bestman::manage_hostcert {
    file { '/etc/grid-security/hostcert.pem':
      ensure => 'file',
      owner  => 'root',
      group  => 'root',
      mode   => '0444',
      source => $osg::bestman::_hostcert_source,
    }

    file { '/etc/grid-security/hostkey.pem':
      ensure => 'file',
      owner  => 'root',
      group  => 'root',
      mode   => '0400',
      source => $osg::bestman::_hostkey_source,
    }

    # File show_diff only in Puppet >= 3.2.0
    if versioncmp($::puppetversion, '3.2.0') >= 0 {
      File <| title == '/etc/grid-security/hostcert.pem' |> { show_diff => false }
      File <| title == '/etc/grid-security/hostkey.pem' |> { show_diff => false }
    }
  }

  file { '/etc/grid-security/bestman':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { '/etc/grid-security/bestman/bestmancert.pem':
    ensure  => 'file',
    owner   => 'bestman',
    group   => 'bestman',
    mode    => '0444',
    source  => $osg::bestman::_bestmancert_source,
    require => File['/etc/grid-security/bestman'],
  }

  file { '/etc/grid-security/bestman/bestmankey.pem':
    ensure  => 'file',
    owner   => 'bestman',
    group   => 'bestman',
    mode    => '0400',
    source  => $osg::bestman::_bestmankey_source,
    require => File['/etc/grid-security/bestman'],
  }

  # File show_diff only in Puppet >= 3.2.0
  if versioncmp($::puppetversion, '3.2.0') >= 0 {
    File <| title == '/etc/grid-security/bestman/bestmancert.pem' |> { show_diff => false }
    File <| title == '/etc/grid-security/bestman/bestmankey.pem' |> { show_diff => false }
  }

  file { '/etc/sysconfig/bestman2':
    ensure  => 'file',
    content => template('osg/bestman/bestman2.sysconfig.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  file { '/etc/bestman2/conf/bestman2.rc':
    ensure  => 'file',
    content => template('osg/bestman/bestman2.rc.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  file { '/var/log/bestman2':
    ensure => 'directory',
    owner  => 'bestman',
    group  => 'bestman',
    mode   => '0755',
  }
}
