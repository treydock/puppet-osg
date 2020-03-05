# Private class: See README.md.
class osg::ce::config {

  file { '/etc/condor-ce/config.d/99-local.conf':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $osg::ce::condor_ce_config_content,
    source  => $osg::ce::condor_ce_config_source,
    notify  => Service['condor-ce'],
  }

  file { $osg::ce::blahp_submit_attributes:
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => $osg::ce::blahp_local_submit_content,
    source  => $osg::ce::blahp_local_submit_source,
  }

  if $osg::ce::batch_system != 'condor' {
    file_line { 'blah_disable_wn_proxy_renewal':
      path  => '/etc/blah.config',
      line  => 'blah_disable_wn_proxy_renewal="yes"',
      match => '^blah_disable_wn_proxy_renewal=.*',
    }

    file_line { 'blah_delegate_renewed_proxies':
      path  => '/etc/blah.config',
      line  => 'blah_delegate_renewed_proxies="no"',
      match => '^blah_delegate_renewed_proxies=.*',
    }

    file_line { 'blah_disable_limited_proxy':
      path  => '/etc/blah.config',
      line  => 'blah_disable_limited_proxy="yes"',
      match => '^blah_disable_limited_proxy=.*',
    }

    augeas { 'gratia-SuppressNoDNRecords':
      lens    => 'Xml.lns',
      incl    => $osg::ce::gratia_probe_config,
      context => "/files${osg::ce::gratia_probe_config}/ProbeConfiguration/#attribute",
      changes => [
        'set EnableProbe 1',
        'set SuppressNoDNRecords 1',
      ],
    }
  }

  if $osg::ce::include_view {
    augeas { 'htcondor-ce-view HTCONDORCE_VIEW_PORT':
      lens    => 'Simplevars.lns',
      incl    => '/etc/condor-ce/config.d/05-ce-view.conf',
      changes => [
        'set DAEMON_LIST "$(DAEMON_LIST), CEVIEW, GANGLIAD"',
        "set HTCONDORCE_VIEW_PORT ${osg::ce::view_port}",
      ],
      notify  => Service['condor-ce'],
    }
  }

  osg_local_site_settings { 'Gateway/htcondor_gateway_enabled':
    value => true
  }

  osg_local_site_settings { 'Storage/grid_dir': value => $osg::ce::storage_grid_dir }
  osg_local_site_settings { 'Storage/app_dir': value => $osg::ce::storage_app_dir }
  osg_local_site_settings { 'Storage/data_dir': value => $osg::ce::storage_data_dir }
  osg_local_site_settings { 'Storage/worker_node_temp': value => $osg::ce::storage_worker_node_temp }
  osg_local_site_settings { 'Storage/site_read': value => $osg::ce::storage_site_read }
  osg_local_site_settings { 'Storage/site_write': value => $osg::ce::storage_site_write }

  osg_local_site_settings { 'Network/port_range': value => "${osg::globus_tcp_source_range_min},${osg::globus_tcp_source_range_max}"}

  osg_local_site_settings { "${osg::ce::batch_ini_section}/enabled": value => true }
  osg_local_site_settings { "${osg::ce::batch_ini_section}/${osg::ce::location_name}": value => $osg::ce::batch_system_prefix }
  osg_local_site_settings { "${osg::ce::batch_ini_section}/job_contact": value => "${osg::site_info_host_name}/${osg::ce::job_contact}" }
  osg_local_site_settings { "${osg::ce::batch_ini_section}/util_contact": value => "${osg::site_info_host_name}/${osg::ce::util_contact}" }
  create_resources(osg_local_site_settings, $osg::ce::batch_settings)

  create_resources(osg_local_site_settings, $osg::ce::osg_local_site_settings)
  create_resources(osg_gip_config, $osg::ce::osg_gip_configs)

  if $osg::enable_exported_resources {
    Osg_local_site_settings <<| tag == $osg::exported_resource_collect_tag |>> {
      notify  => Exec['osg-configure'],
      require => Class['osg::ce::install'],
    }
  }

}
