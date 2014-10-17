# == Class: osg::ce::install
#
class osg::ce::install {

  if $osg::ce::gram_gateway_enabled {
    package { $osg::ce::batch_system_package_name:
      ensure  => 'present',
      before  => Package['osg-ce'],
    }
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

    package { 'gratia-probe-slurm':
      ensure  => 'present',
      require => Package['osg-ce'],
    }
  }

}
