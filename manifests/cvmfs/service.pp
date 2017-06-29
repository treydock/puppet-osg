# Private class: See README.md.
class osg::cvmfs::service {

  exec { 'cvmfs_config reload':
    refreshonly => true,
    path        => '/usr/bin:/usr/sbin:/bin:/sbin',
    subscribe   => [ File['/etc/cvmfs/default.local'], File['/etc/cvmfs/domain.d/cern.ch.local'] ],
  }

}
