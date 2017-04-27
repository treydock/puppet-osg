# Private class: See README.md.
class osg::ce::install {

  package { $osg::ce::batch_system_package_name:
    ensure => 'present',
    before => Package[$osg::ce::ce_package_name],
  }

  package { $osg::ce::ce_package_name:
    ensure => 'present',
  }

  package { 'osg-info-services':
    ensure  => 'present',
    require => Package[$osg::ce::ce_package_name],
  }

  if $osg::ce::enable_cleanup {
    package { 'osg-cleanup':
      ensure  => 'present',
      require => Package[$osg::ce::ce_package_name],
    }
  }

}
