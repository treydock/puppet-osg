# == Class: osg::ce
#
class osg::ce (
  $batch_system_package_name = 'empty-torque',
  $ce_package_name = 'osg-ce-pbs',
  $use_slurm = false,
  $hostcert_source = 'UNSET',
  $hostkey_source = 'UNSET',
  $httpcert_source = 'UNSET',
  $httpkey_source = 'UNSET',
  $manage_firewall = true,
) inherits osg::params {

  validate_bool($use_slurm)
  validate_bool($manage_firewall)

  include osg

  $cemon_service_name = $osg::osg_release ? {
    /3.1/ => 'tomcat6',
    /3.2/ => 'osg-info-services',
  }

  class { 'osg::gridftp':
    hostcert_source => $hostcert_source,
    hostkey_source  => $hostkey_source,
    manage_firewall => $manage_firewall,
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

  if $manage_firewall {
    firewall { '100 allow GRAM':
      ensure  => 'present',
      action  => 'accept',
      dport   => '2119',
      proto   => 'tcp',
    }
  }

}
