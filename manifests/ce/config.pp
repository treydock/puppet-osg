# == Class: osg::ce::config
#
class osg::ce::config {

  $httpcert_source = $osg::ce::httpcert_source ? {
    'UNSET' => undef,
    default => $osg::ce::httpcert_source,
  }

  $httpkey_source = $osg::ce::httpkey_source ? {
    'UNSET' => undef,
    default => $osg::ce::httpkey_source,
  }

  file { '/etc/grid-security/http':
    ensure => 'directory',
    owner  => 'tomcat',
    group  => 'tomcat',
    mode   => '0755',
  }

  file { '/etc/grid-security/http/httpcert.pem':
    ensure  => 'file',
    owner   => 'tomcat',
    group   => 'tomcat',
    mode    => '0444',
    source  => $httpcert_source,
    require => File['/etc/grid-security/http'],
  }

  file { '/etc/grid-security/http/httpkey.pem':
    ensure  => 'file',
    owner   => 'tomcat',
    group   => 'tomcat',
    mode    => '0400',
    source  => $httpkey_source,
    require => File['/etc/grid-security/http'],
  }

  osg_local_site_settings { 'Gateway/gram_gateway_enabled':
    value => $osg::ce::gram_gateway_enabled
  }

  osg_local_site_settings { 'Gateway/htcondor_gateway_enabled':
    value => $osg::ce::htcondor_gateway_enabled
  }

  # TODO Manage /etc/condor-ce/config.d/99-local.conf

}
