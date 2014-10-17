# == Class: osg::ce
#
class osg::ce (
  $gram_gateway_enabled = true,
  $htcondor_gateway_enabled = true,
  $batch_system_package_name = 'empty-torque',
  $ce_package_name = 'osg-ce-pbs',
  $use_slurm = false,
  $hostcert_source = 'UNSET',
  $hostkey_source = 'UNSET',
  $httpcert_source = 'UNSET',
  $httpkey_source = 'UNSET',
  $htcondor_ce_port = '9619',
  $htcondor_ce_shared_port = '9620',
  $manage_firewall = true,
) inherits osg::params {

  validate_bool($gram_gateway_enabled)
  validate_bool($htcondor_gateway_enabled)
  validate_bool($use_slurm)
  validate_bool($manage_firewall)

  include osg
  include osg::cacerts

  $cemon_service_name = $osg::osg_release ? {
    /3.1/ => 'tomcat6',
    /3.2/ => 'osg-info-services',
  }

  class { 'osg::gridftp':
    hostcert_source => $hostcert_source,
    hostkey_source  => $hostkey_source,
    manage_firewall => $manage_firewall,
    standalone      => false,
  }

  anchor { 'osg::ce::start': }->
  Class['osg']->
  Class['osg::cacerts']->
  class { 'osg::ce::install': }->
  Class['osg::gridftp']->
  class { 'osg::ce::config': }->
  class { 'osg::ce::service': }->
  anchor { 'osg::ce::end': }

  if $manage_firewall {
    if $gram_gateway_enabled {
      firewall { '100 allow GRAM':
        ensure  => 'present',
        action  => 'accept',
        dport   => '2119',
        proto   => 'tcp',
      }
    }

    if $htcondor_gateway_enabled {
      firewall { '100 allow HTCondorCE':
        ensure  => 'present',
        action  => 'accept',
        dport   => $htcondor_ce_port,
        proto   => 'tcp',
      }
      firewall { '100 allow HTCondorCE shared_port':
        ensure  => 'present',
        action  => 'accept',
        dport   => $htcondor_ce_shared_port,
        proto   => 'tcp',
      }
    }
  }

}
