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

  file { '/etc/condor-ce/config.d/99-local.conf':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $osg::ce::condor_ce_config_content,
    source  => $osg::ce::condor_ce_config_source,
    notify  => Service['condor-ce'],
  }

  if $osg::ce::batch_system != 'condor' {
    file_line { 'blah_disable_wn_proxy_renewal':
      path  => '/etc/blah.config',
      line  => 'blah_disable_wn_proxy_renewal="yes"',
      match => '^blah_disable_wn_proxy_renewal=.*',
    }

    file_line { 'blah_delegate_renewed_proxies':
      path  => '/etc/blah.config',
      line  => 'blah_delegate_renewed_proxies=no',
      match => '^blah_delegate_renewed_proxies=.*',
    }

    file_line { 'blah_disable_limited_proxy':
      path  => '/etc/blah.config',
      line  => 'blah_disable_limited_proxy=yes',
      match => '^blah_disable_limited_proxy=.*',
    }
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

  osg_local_site_settings { "${osg::ce::batch_ini_section}/enabled": value => true }
  osg_local_site_settings { "${osg::ce::batch_ini_section}/${osg::ce::location_name}": value => $osg::ce::batch_system_prefix }
  osg_local_site_settings { "${osg::ce::batch_ini_section}/job_contact": value => "${osg::ce::site_info_host_name}/${osg::ce::job_contact}" }
  osg_local_site_settings { "${osg::ce::batch_ini_section}/util_contact": value => "${osg::ce::site_info_host_name}/${osg::ce::util_contact}" }
  create_resources(osg_local_site_settings, $osg::ce::batch_settings)

  osg_local_site_settings { 'Misc Services/enable_cleanup': value => $osg::ce::enable_cleanup }

  create_resources(osg_local_site_settings, $osg::ce::osg_local_site_settings)
  create_resources(osg_gip_config, $osg::ce::osg_gip_configs)

  if $osg::enable_exported_resources {
    Osg_local_site_settings <<| tag == $osg::exported_resource_collect_tag |>> {
      notify  => Exec['osg-configure'],
      require => Class['osg::ce::install'],
    }
  }

}
