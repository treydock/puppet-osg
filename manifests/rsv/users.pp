# Private class: See README.md.
class osg::rsv::users {

  if $osg::rsv::manage_users {
    user { 'rsv':
      ensure     => 'present',
      name       => 'rsv',
      uid        => $osg::rsv::rsv_uid,
      gid        => 'rsv',
      home       => '/var/rsv',
      shell      => '/bin/sh',
      system     => true,
      comment    => 'RSV monitoring',
      managehome => false,
    }

    group { 'rsv':
      ensure => present,
      name   => 'rsv',
      gid    => $osg::rsv::rsv_gid,
      system => true,
    }

    user { 'cndrcron':
      ensure     => 'present',
      name       => 'cndrcron',
      uid        => $osg::rsv::cndrcron_uid,
      gid        => 'cndrcron',
      home       => '/var/lib/condor-cron',
      shell      => '/sbin/nologin',
      system     => true,
      comment    => 'Condor-cron service',
      managehome => false,
    }

    group { 'cndrcron':
      ensure => present,
      name   => 'cndrcron',
      gid    => $osg::rsv::cndrcron_gid,
      system => true,
    }
  }
}
