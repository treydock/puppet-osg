# == Class: osg::bestman::config
#
class osg::bestman::config {

  include osg
  include osg::bestman

  $gums_host = $osg::gums_host

  $hostcert_source = $osg::bestman::hostcert_source ? {
    'UNSET' => undef,
    default => $osg::bestman::hostcert_source,
  }

  $hostkey_source = $osg::bestman::hostkey_source ? {
    'UNSET' => undef,
    default => $osg::bestman::hostkey_source,
  }

  $bestmancert_source = $osg::bestman::bestmancert_source ? {
    'UNSET' => undef,
    default => $osg::bestman::bestmancert_source,
  }

  $bestmankey_source = $osg::bestman::bestmankey_source ? {
    'UNSET' => undef,
    default => $osg::bestman::bestmankey_source,
  }

  $host_dn = $osg::bestman::host_dn ? {
    'UNSET' => "/DC=com/DC=DigiCert-Grid/O=Open Science Grid/OU=Services/CN=${::fqdn}",
    default => $osg::bestman::host_dn,
  }

  if $osg::bestman::manage_sudo {
    sudo::conf { 'bestman':
      priority => 10,
      content  => template('osg/bestman/bestman.sudo.erb'),
    }
  }

  file { '/etc/grid-security/hostcert.pem':
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0444',
    source => $hostcert_source,
  }

  file { '/etc/grid-security/hostkey.pem':
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0400',
    source => $hostkey_source,
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
    source  => $bestmancert_source,
    require => File['/etc/grid-security/bestman'],
  }

  file { '/etc/grid-security/bestman/bestmankey.pem':
    ensure  => 'file',
    owner   => 'bestman',
    group   => 'bestman',
    mode    => '0400',
    source  => $bestmankey_source,
    require => File['/etc/grid-security/bestman'],
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
