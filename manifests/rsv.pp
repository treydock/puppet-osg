# Class: osg::rsv: See README.md for documentation.
class osg::rsv (
  Optional[String] $rsvcert_source = undef,
  Optional[String] $rsvkey_source = undef,
  Boolean $manage_users = true,
  Boolean $with_httpd = true,
  Boolean $manage_firewall = true,
  Enum['present', 'absent'] $firewall_ensure = 'present',
  Integer[0, 65535] $http_port = 80,
  Optional[Integer] $rsv_uid = undef,
  Optional[Integer] $rsv_gid = undef,
  Integer $cndrcron_uid = 93,
  Integer $cndrcron_gid = 93,
  String $gram_ce_hosts = 'UNAVAILABLE',
  String $htcondor_ce_hosts = 'UNAVAILABLE',
  String $ce_hosts = 'UNAVAILABLE',
  String $gridftp_hosts = 'UNAVAILABLE',
  String $gridftp_dir = 'DEFAULT',
  String $gratia_probes = 'DEFAULT',
  String $srm_hosts = 'UNAVAILABLE',
  String $srm_dir = 'DEFAULT',
  String $srm_webservice_path = 'DEFAULT',
) inherits osg::params {

  include osg
  include osg::cacerts

  include osg::rsv::users
  include osg::rsv::install
  include osg::rsv::config
  include osg::rsv::service

  anchor { 'osg::rsv::start': }
  anchor { 'osg::rsv::end': }

  Anchor['osg::rsv::start']
  -> Class['osg']
  -> Class['osg::cacerts']
  -> Class['osg::rsv::users']
  -> Class['osg::rsv::install']
  -> Class['osg::rsv::config']
  ~> Class['osg::rsv::service']
  -> Anchor['osg::rsv::end']

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
