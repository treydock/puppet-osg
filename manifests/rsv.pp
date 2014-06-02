# == Class: osg::rsv
#
# Installs and configures RSV for use with OSG.
#
# === Parameters
#
# === Examples
#
#  class { 'osg::rsv': }
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2013 Trey Dockendorf
#
class osg::rsv (
  $rsvcert_source         = 'UNSET',
  $rsvkey_source          = 'UNSET',
  $with_httpd             = true,
  $manage_firewall        = true,
  $http_port              = '80',
  $cndrcron_uid           = '93',
  $cndrcron_gid           = '93',
  $ce_hosts               = 'UNAVAILABLE',
  $gridftp_hosts          = 'UNAVAILABLE',
  $gridftp_dir            = 'DEFAULT',
  $gratia_probes          = 'DEFAULT',
  $srm_hosts              = 'UNAVAILABLE',
  $srm_dir                = 'DEFAULT',
  $srm_webservice_path    = 'DEFAULT',
) inherits osg::params {

  validate_bool($with_httpd)
  validate_bool($manage_firewall)

  include osg
  include osg::cacerts
  include osg::rsv::install
  include osg::rsv::config
  include osg::rsv::service

  anchor { 'osg::rsv::start': }
  anchor { 'osg::rsv::end': }

  Anchor['osg::rsv::start']->
  Class['osg::repo']->
  Class['osg::cacerts']->
  Class['osg::rsv::install']->
  Class['osg::rsv::config']~>
  Class['osg::rsv::service']->
  Anchor['osg::rsv::end']

  if $with_httpd {
    if $manage_firewall {
      firewall { '100 allow RSV http access':
        dport   => $http_port,
        proto   => tcp,
        action  => accept,
      }
    }

    include apache
  }

}
