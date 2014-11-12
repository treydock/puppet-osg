# == Class: osg::cvmfs::user
#
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
