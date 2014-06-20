# == Class: osg::cvmfs
#
# Installs and configures a cvmfs client for use with OSG.
#
# === Parameters
#
# === Examples
#
#  class { 'osg::cvmfs': }
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2014 Trey Dockendorf
#
class osg::cvmfs::config {

  file { '/etc/fuse.conf':
    ensure  => 'file',
    path    => '/etc/fuse.conf',
    content => "user_allow_other\n",
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Service['autofs'],
  }

  file_line { 'auto.master cvmfs':
    ensure  => 'present',
    path    => '/etc/auto.master',
    line    => '/cvmfs /etc/auto.cvmfs',
    match   => '^/cvmfs.*',
    notify  => Service['autofs'],
  }

  file { '/etc/cvmfs/default.local':
    ensure  => 'file',
    path    => '/etc/cvmfs/default.local',
    content => template('osg/cvmfs/default.local.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  file { '/etc/cvmfs/domain.d/cern.ch.local':
    ensure  => 'file',
    path    => '/etc/cvmfs/domain.d/cern.ch.local',
    content => template('osg/cvmfs/cern.ch.local.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

}
