# == Class: osg::ce
#
class osg::ce (
  $batch_system_package_name = 'empty-torque',
  $ce_package_name = 'osg-ce-pbs',
  $use_slurm = true,
  $hostcert_source = 'UNSET',
  $hostkey_source = 'UNSET',
  $httpcert_source = 'UNSET',
  $htpkey_source = 'UNSET',
) inherits osg::params {

  include osg

  $cemon_service_name = $osg::osg_release ? {
    /3.0|3.1/ => 'tomcat6',
    /3.2/     => 'osg-info-services',
  }

  include osg::repo
  include osg::cacerts
  include osg::gums::client
  include osg::ce::install
  include osg::ce::config
  include osg::ce::service

  anchor { 'osg::ce::start': }
  anchor { 'osg::ce::end': }

  Anchor['osg::ce::start']->
  Class['osg::repo']->
  Class['osg::cacerts']->
  Class['osg::ce::install']->
  Osg_config<| |>->
  Class['osg::ce::config']->
  Class['osg::ce::service']->
  Anchor['osg::ce::end']

}
