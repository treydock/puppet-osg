# Private class: See README.md.
class osg::ce::config {

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
    source  => $osg::ce::_httpcert_source,
    require => File['/etc/grid-security/http'],
  }

  file { '/etc/grid-security/http/httpkey.pem':
    ensure  => 'file',
    owner   => 'tomcat',
    group   => 'tomcat',
    mode    => '0400',
    source  => $osg::ce::_httpkey_source,
    require => File['/etc/grid-security/http'],
  }

  # File show_diff only in Puppet >= 3.2.0
  if versioncmp($::puppetversion, '3.2.0') >= 0 {
    File <| title == '/etc/grid-security/http/httpcert.pem' |> { show_diff => false }
    File <| title == '/etc/grid-security/http/httpkey.pem' |> { show_diff => false }
  }

  osg_local_site_settings { 'Gateway/gram_gateway_enabled':
    value => $osg::ce::gram_gateway_enabled
  }

  osg_local_site_settings { 'Gateway/htcondor_gateway_enabled':
    value => $osg::ce::htcondor_gateway_enabled
  }

  osg_local_site_settings { 'Site Information/group': value => $osg::ce::site_info_group }
  osg_local_site_settings { 'Site Information/host_name': value => $osg::ce::site_info_host_name }
  osg_local_site_settings { 'Site Information/resource': value => $osg::ce::site_info_resource }
  osg_local_site_settings { 'Site Information/resource_group': value => $osg::ce::site_info_resource_group }
  osg_local_site_settings { 'Site Information/sponsor': value => $osg::ce::site_info_sponsor }
  osg_local_site_settings { 'Site Information/site_policy': value => $osg::ce::site_info_site_policy }
  osg_local_site_settings { 'Site Information/contact': value => $osg::ce::site_info_contact }
  osg_local_site_settings { 'Site Information/email': value => $osg::ce::site_info_email }
  osg_local_site_settings { 'Site Information/city': value => $osg::ce::site_info_city }
  osg_local_site_settings { 'Site Information/country': value => $osg::ce::site_info_country }
  osg_local_site_settings { 'Site Information/longitude': value => $osg::ce::site_info_longitude }
  osg_local_site_settings { 'Site Information/latitude': value => $osg::ce::site_info_latitude }

  osg_local_site_settings { 'Network/port_range': value => "${osg::globus_tcp_source_range_min},${osg::globus_tcp_source_range_max}"}

  create_resources(osg_local_site_settings, $osg::ce::osg_local_site_settings)
  create_resources(osg_gip_config, $osg::ce::osg_gip_configs)

  if $osg::enable_exported_resources {
    Osg_local_site_settings <<| tag == $osg::exported_resource_collect_tag |>>
  }

}
