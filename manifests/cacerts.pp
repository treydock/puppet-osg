# == Class: osg::cacerts
#
# Adds the OSG CA cert packages for OSG.
#
#
class osg::cacerts inherits osg::params {

  include osg

  $package_name   = $osg::cacerts_package_name
  $package_ensure = $osg::cacerts_package_ensure

  package { 'osg-ca-certs':
    ensure  => $package_ensure,
    name    => $package_name,
    require => Yumrepo['osg'],
  }

  file { '/etc/grid-security':
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }

  if $package_name == 'empty-ca-certs' {
    file { '/etc/grid-security/certificates':
      ensure  => 'link',
      target  => $osg::shared_certs_path,
      require => File['/etc/grid-security'],
    }
  }

}
