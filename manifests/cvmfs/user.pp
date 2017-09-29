# Private class: See README.md.
class osg::cvmfs::user {

  if $osg::cvmfs::manage_fuse_group and versioncmp($::operatingsystemrelease, '7.0') < 0 {
    if $osg::cvmfs::manage_user {
      $_fuse_group_before = User['cvmfs']
    } else {
      $_fuse_group_before = undef
    }
    group { 'fuse':
      ensure     => 'present',
      name       => $osg::cvmfs::fuse_group_name,
      gid        => $osg::cvmfs::fuse_group_gid,
      system     => $osg::cvmfs::fuse_group_system,
      before     => $_fuse_group_before,
      forcelocal => true,
    }
  }

  if $osg::cvmfs::manage_user {
    if versioncmp($::operatingsystemrelease, '7.0') < 0 {
      $cvmfs_groups = ['fuse']
    } else {
      $cvmfs_groups = undef
    }

    user { 'cvmfs':
      ensure     => 'present',
      name       => $osg::cvmfs::user_name,
      uid        => $osg::cvmfs::user_uid,
      gid        => $osg::cvmfs::group_name,
      groups     => $cvmfs_groups,
      home       => $osg::cvmfs::user_home,
      shell      => $osg::cvmfs::user_shell,
      system     => $osg::cvmfs::user_system,
      comment    => $osg::cvmfs::user_comment,
      managehome => $osg::cvmfs::user_managehome,
      forcelocal => true,
    }
  }

  if $osg::cvmfs::manage_group {
    group { 'cvmfs':
      ensure     => 'present',
      name       => $osg::cvmfs::group_name,
      gid        => $osg::cvmfs::group_gid,
      system     => $osg::cvmfs::group_system,
      forcelocal => true,
    }
  }

}
