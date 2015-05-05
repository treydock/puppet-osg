# Private class: See README.md.
class osg::cvmfs::service {

  if !defined(Service['autofs']) {
    service { 'autofs':
      ensure     => 'running',
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
    }
  }

  exec { 'cvmfs_config reload':
    refreshonly => true,
    path        => '/usr/bin:/usr/sbin:/bin:/sbin',
    subscribe   => [ File['/etc/cvmfs/default.local'], File['/etc/cvmfs/domain.d/cern.ch.local'] ],
  }

}
