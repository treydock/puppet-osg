# Private class: See README.md.
class osg::cacerts inherits osg::params {

  include osg

  $package_name   = $osg::cacerts_package_name
  $package_ensure = $osg::cacerts_package_ensure

  package { 'osg-ca-certs':
    ensure  => $package_ensure,
    name    => $package_name,
    require => Yumrepo['osg'],
  }

  if $::osg::cacerts_install_other_packages {
    package { 'cilogon-ca-certs':
      ensure  => $::osg::cacerts_other_packages_ensure,
      require => Yumrepo['osg'],
    }
  }

  file { '/etc/grid-security':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    before => File['/etc/grid-security/certificates'],
  }

  if $package_name == 'empty-ca-certs' {
    file { '/etc/grid-security/certificates':
      ensure => 'link',
      target => $osg::shared_certs_path,
      before => Package['osg-ca-certs'],
    }
  } else {
    file { '/etc/grid-security/certificates':
      ensure => 'directory',
      before => Package['osg-ca-certs'],
    }
  }

}
