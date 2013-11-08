# == Class: osg::bestman
#
# Installs and configures a Bestman SE for use with OSG.
#
# === Parameters
#
# === Examples
#
#  class { 'osg::bestman': }
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2013 Trey Dockendorf
#
class osg::bestman (
  $user_name              = 'bestman',
  $ca_certs_type          = 'empty',
  $with_gridmap_auth      = false,
  $grid_map_file_name     = '/etc/bestman2/conf/grid-mapfile.empty',
  $with_gums_auth         = true,
  $gums_hostname          = 'UNSET',
  $gums_port              = '8443',
  $gums_protocol          = 'XACML',
  $bestman_gumscertpath   = '/etc/grid-security/bestman/bestmancert.pem',
  $bestman_gumskeypath    = '/etc/grid-security/bestman/bestmankey.pem',
  $manage_firewall        = true,
  $port                   = '8443',
  $firewall_interface     = 'eth0',
  $localPathListToBlock   = [],
  $localPathListAllowed   = [],
  $cert_file_name         = '/etc/grid-security/bestman/bestmancert.pem',
  $key_file_name          = '/etc/grid-security/bestman/bestmankey.pem',
  $supportedProtocolList  = [],
  $noSudoOnLs             = true,
  $accessFileSysViaGsiftp = false,
  $service_ensure         = 'running',
  $service_enable         = true,
  $service_autorestart    = true,
) inherits osg::params {

  validate_re($ca_certs_type, '^(osg|igtf|empty)$')
  validate_bool($with_gridmap_auth)
  validate_bool($with_gums_auth)
  validate_bool($manage_firewall)
  validate_array($localPathListToBlock)
  validate_array($localPathListAllowed)
  validate_array($supportedProtocolList)

  if $with_gridmap_auth and $with_gums_auth {
    fail('with_gridmap_auth and with_gums_auth cannot both be true')
  }

  $ca_certs_class = $ca_certs_type ? {
    /igtf/  => 'osg::cacerts::igtf',
    /osg/   => 'osg::cacerts',
    default => 'osg::cacerts::empty',
  }

  # This gives the option to not manage the service 'ensure' state.
  $service_ensure_real = $service_ensure ? {
    'undef' => undef,
    default => $service_ensure,
  }

  # This gives the option to not manage the service 'enable' state.
  $service_enable_real = $service_enable ? {
    'undef' => undef,
    default => $service_enable,
  }

  $service_subscribe = $service_autorestart ? {
    true  => [ File['/etc/sysconfig/bestman2'], File['/etc/bestman2/conf/bestman2.rc'] ],
    false => undef,
  }

  require  $ca_certs_class

  if $with_gums_auth {
    require 'osg::lcmaps'

    $gums_hostname_real = $gums_hostname ? {
      'UNSET' => $osg::lcmaps::gums_hostname,
      default => $gums_hostname,
    }
  }

  if $manage_firewall {
    require 'firewall'

    firewall { '100 allow bestman2 access':
      port    => $port,
      proto   => tcp,
      iniface => $firewall_interface,
      action  => accept,
    }
  }

  package { 'osg-se-bestman':
    ensure  => installed,
    require => Yumrepo['osg'],
    before  => [ File['/etc/sysconfig/bestman2'], File['/etc/bestman2/conf/bestman2.rc'] ]
  }

  file { '/etc/sysconfig/bestman2':
    ensure  => present,
    content => template('osg/bestman/bestman2.sysconfig.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  file { '/etc/bestman2/conf/bestman2.rc':
    ensure  => present,
    content => template('osg/bestman/bestman2.rc.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  service { 'bestman2':
    ensure      => $service_ensure_real,
    enable      => $service_enable_real,
    hasstatus   => true,
    hasrestart  => true,
    subscribe   => $service_subscribe,
  }

}
