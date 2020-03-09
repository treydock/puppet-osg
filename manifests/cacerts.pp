# @summary Manage OSG CA certs
# @api private
class osg::cacerts {

  include osg

  $package_name   = $osg::cacerts_package_name
  $package_ensure = $osg::cacerts_package_ensure

  if $package_name != 'empty-ca-certs' {
    contain osg::fetchcrl
  }

  package { 'osg-ca-certs':
    ensure  => $package_ensure,
    name    => $package_name,
    require => Yumrepo['osg'],
  }

  if ! defined(File['/etc/grid-security']) {
    file { '/etc/grid-security':
      ensure => 'directory',
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }
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
