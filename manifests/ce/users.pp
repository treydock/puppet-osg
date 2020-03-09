# @summary Manage OSG CE Users
# @api private
class osg::ce::users {

  if $osg::ce::manage_users {
    user { 'condor':
      ensure     => 'present',
      name       => 'condor',
      uid        => $osg::ce::condor_uid,
      gid        => 'condor',
      home       => '/var/lib/condor',
      shell      => '/sbin/nologin',
      system     => true,
      comment    => 'Owner of HTCondor Daemons',
      managehome => false,
      forcelocal => true,
    }

    group { 'condor':
      ensure     => present,
      name       => 'condor',
      gid        => $osg::ce::condor_gid,
      system     => true,
      forcelocal => true,
    }

    user { 'gratia':
      ensure     => 'present',
      name       => 'gratia',
      uid        => $osg::ce::gratia_uid,
      gid        => 'gratia',
      home       => '/etc/gratia',
      shell      => '/sbin/nologin',
      system     => true,
      comment    => 'gratia runtime user',
      managehome => false,
      forcelocal => true,
    }

    group { 'gratia':
      ensure     => present,
      name       => 'gratia',
      gid        => $osg::ce::gratia_gid,
      system     => true,
      forcelocal => true,
    }
  }
}
