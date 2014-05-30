# == Class: osg::wn
#
class osg::wn (
  $cacerts_package_name = 'empty-ca-certs',
  $cacerts_package_ensure = 'installed',
) inherits osg::params {

  include osg

  class { 'osg::cacerts':
    package_name    => $cacerts_package_name,
    package_ensure  => $cacerts_package_ensure,
  }

  package { 'osg-wn-client':
    ensure  => 'present',
  }

  anchor { 'osg::wn::start': }
  anchor { 'osg::wn::end': }

  Anchor['osg::wn::start']->
  Class['osg::repo']->
  Class['osg::cacerts']->
  Package['osg-wn-client']->
  Anchor['osg::wn::end']

}
