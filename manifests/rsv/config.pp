# Private class: See README.md.
class osg::rsv::config {

  osg_local_site_settings { 'RSV/ce_hosts':            value => $osg::rsv::ce_hosts }
  osg_local_site_settings { 'RSV/gram_ce_hosts':       value => $osg::rsv::gram_ce_hosts }
  osg_local_site_settings { 'RSV/htcondor_ce_hosts':   value => $osg::rsv::htcondor_ce_hosts }
  osg_local_site_settings { 'RSV/gridftp_hosts':       value => $osg::rsv::gridftp_hosts }
  osg_local_site_settings { 'RSV/gridftp_dir':         value => $osg::rsv::gridftp_dir }
  osg_local_site_settings { 'RSV/gratia_probes':       value => $osg::rsv::gratia_probes }
  osg_local_site_settings { 'RSV/srm_hosts':           value => $osg::rsv::srm_hosts }
  osg_local_site_settings { 'RSV/srm_dir':             value => $osg::rsv::srm_dir }
  osg_local_site_settings { 'RSV/srm_webservice_path': value => $osg::rsv::srm_webservice_path }

  file { '/etc/grid-security/rsv':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { '/etc/grid-security/rsv/rsvcert.pem':
    ensure  => 'file',
    owner   => 'rsv',
    group   => 'rsv',
    mode    => '0444',
    source  => $osg::rsv::_rsvcert_source,
    require => File['/etc/grid-security/rsv'],
  }

  file { '/etc/grid-security/rsv/rsvkey.pem':
    ensure  => 'file',
    owner   => 'rsv',
    group   => 'rsv',
    mode    => '0400',
    source  => $osg::rsv::_rsvkey_source,
    require => File['/etc/grid-security/rsv'],
  }

  file { '/var/spool/rsv':
    ensure => 'directory',
    owner  => 'rsv',
    group  => 'rsv',
    mode   => '0755',
  }

  file { '/var/log/rsv':
    ensure => 'directory',
    owner  => 'rsv',
    group  => 'rsv',
    mode   => '0755',
  }

  file { '/var/log/rsv/consumers':
    ensure  => 'directory',
    owner   => 'rsv',
    group   => 'rsv',
    mode    => '0755',
    require => File['/var/log/rsv'],
  }

  file { '/var/log/rsv/metrics':
    ensure  => 'directory',
    owner   => 'rsv',
    group   => 'rsv',
    mode    => '0755',
    require => File['/var/log/rsv'],
  }

  file { '/etc/condor-cron/config.d/condor_ids':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('osg/rsv/condor_ids.erb'),
  }

  file { '/var/lib/condor-cron':
    ensure => 'directory',
    owner  => 'cndrcron',
    group  => 'cndrcron',
    mode   => '0755',
  }

  file { '/var/lib/condor-cron/execute':
    ensure  => 'directory',
    owner   => 'cndrcron',
    group   => 'cndrcron',
    mode    => '0755',
    require => File['/var/lib/condor-cron']
  }

  file { '/var/lib/condor-cron/spool':
    ensure  => 'directory',
    owner   => 'cndrcron',
    group   => 'cndrcron',
    mode    => '0755',
    require => File['/var/lib/condor-cron']
  }

  file { '/var/run/condor-cron':
    ensure => 'directory',
    owner  => 'cndrcron',
    group  => 'cndrcron',
    mode   => '0755',
  }

  file { '/var/lock/condor-cron':
    ensure => 'directory',
    owner  => 'cndrcron',
    group  => 'cndrcron',
    mode   => '0755',
  }

  file { '/var/log/condor-cron':
    ensure => 'directory',
    owner  => 'cndrcron',
    group  => 'cndrcron',
    mode   => '0755',
  }
}
