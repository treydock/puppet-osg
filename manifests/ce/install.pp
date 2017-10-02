# Private class: See README.md.
class osg::ce::install {

  if $osg::ce::batch_system_package_name {
    package { $osg::ce::batch_system_package_name:
      ensure => 'present',
      before => Package[$osg::ce::ce_package_name],
    }
  }

  package { $osg::ce::ce_package_name:
    ensure => 'present',
  }

  package { 'htcondor-ce-view':
    ensure => $osg::ce::view_ensure,
  }

}
