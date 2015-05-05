# Private class: See README.md.
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
    ensure => 'present',
    path   => '/etc/auto.master',
    line   => '/cvmfs /etc/auto.cvmfs',
    match  => '^/cvmfs.*',
    notify => Service['autofs'],
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

  if $osg::cvmfs::cms_local_site == 'UNSET' or ! $osg::cvmfs::cms_local_site {
    file { '/etc/cvmfs/config.d/cms.cern.ch.local':
      ensure => 'absent',
      path   => '/etc/cvmfs/config.d/cms.cern.ch.local',
    }
  } else {
    file { '/etc/cvmfs/config.d/cms.cern.ch.local':
      ensure  => 'file',
      path    => '/etc/cvmfs/config.d/cms.cern.ch.local',
      content => template('osg/cvmfs/cms.cern.ch.local.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      notify  => Exec['cvmfs_config reload'],
    }
  }

  file { '/var/lib/cvmfs':
    ensure => 'directory',
    owner  => $::osg::cvmfs::user_name,
    group  => $::osg::cvmfs::group_name,
    mode   => '0700',
  }

}
