# Private class: See README.md.
class osg::cvmfs::user {

  include ::osg::cvmfs

  $user_uid = $::osg::cvmfs::user_uid ? {
    /UNSET|undef/ => undef,
    default       => $::osg::cvmfs::user_uid,
  }

  $group_gid = $::osg::cvmfs::group_gid ? {
    /UNSET|undef/ => undef,
    default       => $::osg::cvmfs::group_gid,
  }

  if $osg::cvmfs::manage_fuse_group {
    if $osg::cvmfs::manage_user {
      $_fuse_group_before = User['cvmfs']
    } else {
      $_fuse_group_before = undef
    }
    group { 'fuse':
      ensure => 'present',
      name   => $osg::cvmfs::fuse_group_name,
      gid    => $osg::cvmfs::fuse_group_gid,
      system => $osg::cvmfs::fuse_group_system,
      before => $_fuse_group_before,
    }
  }

  if $::osg::cvmfs::manage_user {
    user { 'cvmfs':
      ensure     => 'present',
      name       => $::osg::cvmfs::user_name,
      uid        => $user_uid,
      gid        => $::osg::cvmfs::group_name,
      groups     => ['fuse'],
      home       => $::osg::cvmfs::user_home,
      shell      => $::osg::cvmfs::user_shell,
      system     => $::osg::cvmfs::user_system,
      comment    => $::osg::cvmfs::user_comment,
      managehome => $::osg::cvmfs::user_managehome,
    }
  }

  if $::osg::cvmfs::manage_group {
    group { 'cvmfs':
      ensure => 'present',
      name   => $::osg::cvmfs::group_name,
      gid    => $group_gid,
      system => $::osg::cvmfs::group_system,
    }
  }

}
