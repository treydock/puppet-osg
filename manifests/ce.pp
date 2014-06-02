# == Class: osg::ce
#
class osg::ce (
  $batch_system_package_name = 'empty-torque',
  $ce_package_name = 'osg-ce-pbs',
  $use_slurm = true,
  $cacerts_package_name = 'empty-ca-certs',
  $cacerts_package_ensure = 'installed',
  $hostcert_source = 'UNSET',
  $hostkey_source = 'UNSET',
  $httpcert_source = 'UNSET',
  $httpkey_source = 'UNSET',
) inherits osg::params {

  include osg

  $cemon_service_name = $osg::osg_release ? {
    /3.1/ => 'tomcat6',
    /3.2/ => 'osg-info-services',
  }

  class { 'osg::gridftp':
    cacerts_package_name    => $cacerts_package_name,
    cacerts_package_ensure  => $cacerts_package_ensure,
    hostcert_source         => $hostcert_source,
    hostkey_source          => $hostkey_source,
  }

  include osg::ce::install
  include osg::ce::config
  include osg::ce::service

  anchor { 'osg::ce::start': }
  anchor { 'osg::ce::end': }

  Anchor['osg::ce::start']->
  Class['osg::gridftp']->
  Class['osg::ce::install']->
  Class['osg::ce::config']->
  Class['osg::ce::service']->
  Anchor['osg::ce::end']

}
