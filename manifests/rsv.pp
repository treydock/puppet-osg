# Class: osg::rsv: See README.md for documentation.
class osg::rsv (
  $rsvcert_source         = 'UNSET',
  $rsvkey_source          = 'UNSET',
  $manage_users           = true,
  $with_httpd             = true,
  $manage_firewall        = true,
  $firewall_ensure        = 'present',
  $http_port              = '80',
  $cndrcron_uid           = '93',
  $cndrcron_gid           = '93',
  $gram_ce_hosts          = 'UNAVAILABLE',
  $htcondor_ce_hosts      = 'UNAVAILABLE',
  $ce_hosts               = 'UNAVAILABLE',
  $gridftp_hosts          = 'UNAVAILABLE',
  $gridftp_dir            = 'DEFAULT',
  $gratia_probes          = 'DEFAULT',
  $srm_hosts              = 'UNAVAILABLE',
  $srm_dir                = 'DEFAULT',
  $srm_webservice_path    = 'DEFAULT',
) inherits osg::params {

  validate_bool($manage_users)
  validate_bool($with_httpd)
  validate_bool($manage_firewall)

  $_rsvcert_source = $rsvcert_source ? {
    'UNSET' => undef,
    default => $rsvcert_source,
  }

  $_rsvkey_source = $rsvkey_source ? {
    'UNSET' => undef,
    default => $rsvkey_source,
  }

  include osg
  include osg::cacerts
  include osg::rsv::users
  include osg::rsv::install
  include osg::rsv::config
  include osg::rsv::service

  anchor { 'osg::rsv::start': }
  anchor { 'osg::rsv::end': }

  Anchor['osg::rsv::start']->
  Class['osg']->
  Class['osg::cacerts']->
  Class['osg::rsv::users']->
  Class['osg::rsv::install']->
  Class['osg::rsv::config']~>
  Class['osg::rsv::service']->
  Anchor['osg::rsv::end']

  if $with_httpd {
    if $manage_firewall {
      firewall { '100 allow RSV http access':
        ensure => $firewall_ensure,
        dport  => $http_port,
        proto  => tcp,
        action => accept,
      }
    }

    include apache

    file { '/etc/httpd/conf.d/rsv.conf':
      ensure  => 'file',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('osg/rsv/rsv.apache.conf.erb'),
      require => Package['httpd'],
      notify  => Service['httpd'],
    }
  }

}
