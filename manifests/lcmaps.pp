# == Class: osg::lcmaps
#
# Installs and configures lcmaps for use with OSG.
#
# === Parameters
#
# === Examples
#
#  class { 'osg::lcmaps': }
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2013 Trey Dockendorf
#
class osg::lcmaps (
  $gums_hostname,
  $gums_port = '8443',
  $with_glexec = true,
  $globus_mapping = 'globus_mapping liblcas_lcmaps_gt4_mapping.so lcmaps_callout',
  $lcmaps_package_ensure = 'installed',
  $lcmaps_globus_package_ensure = 'installed',
  $lcmaps_config_replace = true,
  $lcmaps_globus_config_replace = true
) inherits osg::params {

  validate_bool($with_glexec)
  validate_bool($lcmaps_config_replace)
  validate_bool($lcmaps_globus_config_replace)

  require 'osg::repo'

  package { 'lcmaps':
    ensure  => $lcmaps_package_ensure,
    before  => File['/etc/lcmaps.db'],
    require => Yumrepo['osg'],
  }

  package { 'lcas-lcmaps-gt4-interface':
    ensure  => $lcmaps_globus_package_ensure,
    before  => File['/etc/grid-security/gsi-authz.conf'],
    require => Yumrepo['osg'],
  }

  file { '/etc/lcmaps.db':
    ensure  => present,
    replace => $lcmaps_config_replace,
    content => template('osg/lcmaps/lcmaps.db.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  file { '/etc/grid-security/gsi-authz.conf':
    ensure  => present,
    replace => $lcmaps_globus_config_replace,
    content => template('osg/lcmaps/gsi-authz.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }
}
