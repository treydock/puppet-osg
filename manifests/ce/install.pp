# == Class: osg::ce::install
#
class osg::ce::install {

  package { $osg::ce::batch_system_package_name:
    ensure  => 'present',
    before  => Package['osg-ce'],
  }

  package { 'osg-ce':
    ensure  => 'present',
    name    => $osg::ce::ce_package_name,
  }

  if $osg::ce::use_slurm {
    package { 'osg-configure-slurm':
      ensure  => 'present',
      require => Package['osg-ce'],
    }
  }

}
