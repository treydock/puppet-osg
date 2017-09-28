# Private class: See README.md.
class osg::cvmfs::config {

  file { '/etc/fuse.conf':
    ensure  => 'file',
    path    => '/etc/fuse.conf',
    content => "user_allow_other\n",
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  autofs::mount { 'cvmfs':
    mount          => '/cvmfs',
    mapfile        => '/etc/auto.cvmfs',
    order          => 50,
    mapfile_manage => false,
  }

  file { '/etc/cvmfs/default.local':
    ensure  => 'file',
    path    => '/etc/cvmfs/default.local',
    content => template('osg/cvmfs/default.local.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  if empty($osg::cvmfs::cern_server_urls) {
    file { '/etc/cvmfs/domain.d/cern.ch.local':
      ensure => 'absent',
      path   => '/etc/cvmfs/domain.d/cern.ch.local',
    }
  } else {
    file { '/etc/cvmfs/domain.d/cern.ch.local':
      ensure  => 'file',
      path    => '/etc/cvmfs/domain.d/cern.ch.local',
      content => template('osg/cvmfs/cern.ch.local.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
    }
  }

  if $osg::cvmfs::cms_local_site {
    file { '/etc/cvmfs/config.d/cms.cern.ch.local':
      ensure  => 'file',
      path    => '/etc/cvmfs/config.d/cms.cern.ch.local',
      content => template('osg/cvmfs/cms.cern.ch.local.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      notify  => Exec['cvmfs_config reload'],
    }
  } else {
    file { '/etc/cvmfs/config.d/cms.cern.ch.local':
      ensure => 'absent',
      path   => '/etc/cvmfs/config.d/cms.cern.ch.local',
    }
  }

  file { '/var/lib/cvmfs':
    ensure => 'directory',
    owner  => $osg::cvmfs::user_name,
    group  => $osg::cvmfs::group_name,
    mode   => '0700',
  }

  if $osg::cvmfs::cache_base != '/var/lib/cvmfs' {
    file { $osg::cvmfs::cache_base:
      ensure => 'directory',
      owner  => $osg::cvmfs::user_name,
      group  => $osg::cvmfs::group_name,
      mode   => '0700',
    }
  }

}
