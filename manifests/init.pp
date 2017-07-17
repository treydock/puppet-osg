# Class: osg: See README.md for documentation.
class osg (
  $osg_release                    = $osg::params::osg_release,
  $repo_baseurl_bit               = 'http://repo.grid.iu.edu',
  $repo_development_baseurl_bit   = undef,
  $repo_testing_baseurl_bit       = undef,
  $repo_upcoming_baseurl_bit      = undef,
  $repo_use_mirrors               = true,
  $repo_gpgkey                    = undef,
  $enable_osg_contrib             = false,
  $gums_host                      = undef,
  $cacerts_package_name           = 'osg-ca-certs',
  $cacerts_install_other_packages = false,
  $cacerts_package_ensure         = 'installed',
  $cacerts_other_packages_ensure  = 'latest',
  $shared_certs_path              = '/opt/grid-certificates',
  $globus_tcp_port_range_min      = '40000',
  $globus_tcp_port_range_max      = '41999',
  $globus_tcp_source_range_min    = '40000',
  $globus_tcp_source_range_max    = '41999',
  $condor_lowport                 = '40000',
  $condor_highport                = '41999',
  $condor_schedd_host             = 'UNSET',
  $condor_collector_host          = 'UNSET',
  $enable_exported_resources      = false,
  $exported_resources_export_tag  = $::domain,
  $exported_resource_collect_tag  = $::domain,
  # INI config values
  $squid_location                 = undef,
  $storage_default_se             = undef,
  $storage_grid_dir               = '/etc/osg/wn-client/',
  $storage_app_dir                = 'UNAVAILABLE',
  $storage_data_dir               = 'UNAVAILABLE',
  $storage_worker_node_temp       = 'UNAVAILABLE',
  $storage_site_read              = 'UNAVAILABLE',
  $storage_site_write             = 'UNAVAILABLE',
) inherits osg::params {

  validate_re($osg_release, '^(3.2|3.3)$', 'The osg_release parameter only supports 3.2 and 3.3')
  validate_re($cacerts_package_name, '^(osg-ca-certs|igtf-ca-certs|empty-ca-certs)$')
  validate_bool($repo_use_mirrors)
  validate_bool($enable_osg_contrib)
  validate_bool($cacerts_install_other_packages)
  validate_bool($enable_exported_resources)

  if $::operatingsystemmajrelease == '7' and $osg_release != '3.3' {
    fail("Module ${module_name}: EL7 is only supported with osg_release 3.3")
  }

  $repo_development_baseurl_bit_real  = pick($repo_development_baseurl_bit, $repo_baseurl_bit)
  $repo_testing_baseurl_bit_real      = pick($repo_testing_baseurl_bit, $repo_baseurl_bit)
  $repo_upcoming_baseurl_bit_real     = pick($repo_upcoming_baseurl_bit, $repo_baseurl_bit)
  $_repo_gpgkey                       = pick($repo_gpgkey, "http://repo.grid.iu.edu/osg/${osg_release}/RPM-GPG-KEY-OSG")
  $_gums_host                         = pick($gums_host, "gums.${::domain}")

  anchor { 'osg::start': }
  anchor { 'osg::end': }

  contain ::epel
  contain osg::repos

  Anchor['osg::start']
  -> Class['osg::repos']
  -> Anchor['osg::end']

  include osg::configure

  # Avoid collecting resources intended for export
  Osg_local_site_settings<| tag != $exported_resources_export_tag |> ~> Exec['osg-configure']
  Osg_gip_config <| |> ~> Exec['osg-configure']

}
