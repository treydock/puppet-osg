# @summary Class for common OSG parameters and common resources
#
# @param osg_release
# @param repo_baseurl_bit
# @param repo_development_baseurl_bit
# @param repo_testing_baseurl_bit
# @param repo_upcoming_baseurl_bit
# @param repo_use_mirrors
# @param repo_gpgkey
# @param enable_osg
# @param enable_osg_empty
# @param enable_osg_contrib
# @param manage_epel
# @param auth_type
# @param cacerts_package_name
# @param cacerts_install_other_packages
# @param cacerts_package_ensure
# @param cacerts_other_packages_ensure
# @param shared_certs_path
# @param globus_tcp_port_range_min
# @param globus_tcp_port_range_max
# @param globus_tcp_source_range_min
# @param globus_tcp_source_range_max
# @param condor_lowport
# @param condor_highport
# @param condor_schedd_host
# @param condor_collector_host
# @param enable_exported_resources
# @param exported_resources_export_tag
# @param exported_resource_collect_tag
# @param site_info_group
# @param site_info_host_name
# @param site_info_resource
# @param site_info_resource_group
# @param site_info_sponsor
# @param site_info_site_policy
# @param site_info_contact
# @param site_info_email
# @param site_info_city
# @param site_info_country
# @param site_info_longitude
# @param site_info_latitude
# @param squid_location
# @param purge_local_site_settings
# @param purge_gip_config
#
class osg (
  Enum['3.5'] $osg_release = '3.5',
  Optional[String] $repo_baseurl_bit = 'https://repo.opensciencegrid.org',
  Optional[String] $repo_development_baseurl_bit = undef,
  Optional[String] $repo_testing_baseurl_bit = undef,
  Optional[String] $repo_upcoming_baseurl_bit = undef,
  Boolean $repo_use_mirrors = true,
  Optional[String] $repo_gpgkey = undef,
  Boolean $enable_osg = true,
  Boolean $enable_osg_empty = true,
  Boolean $enable_osg_contrib = false,
  Boolean $manage_epel = true,
  Enum['lcmaps_voms'] $auth_type = 'lcmaps_voms',
  Enum['osg-ca-certs', 'igtf-ca-certs', 'empty-ca-certs'] $cacerts_package_name = 'osg-ca-certs',
  Boolean $cacerts_install_other_packages = false,
  String $cacerts_package_ensure = 'installed',
  String $cacerts_other_packages_ensure = 'latest',
  String $shared_certs_path = '/opt/grid-certificates',
  Integer[0, 65535] $globus_tcp_port_range_min = 40000,
  Integer[0, 65535] $globus_tcp_port_range_max = 41999,
  Integer[0, 65535] $globus_tcp_source_range_min = 40000,
  Integer[0, 65535] $globus_tcp_source_range_max = 41999,
  Integer[0, 65535] $condor_lowport = 40000,
  Integer[0, 65535] $condor_highport = 41999,
  Optional[String] $condor_schedd_host = undef,
  Optional[String] $condor_collector_host = undef,
  Boolean $enable_exported_resources = false,
  String $exported_resources_export_tag = $facts['domain'],
  String $exported_resource_collect_tag = $facts['domain'],
  # INI config values
  String $site_info_group = 'OSG',
  String $site_info_host_name = $::fqdn,
  String $site_info_resource = 'UNAVAILABLE',
  String $site_info_resource_group = 'UNAVAILABLE',
  String $site_info_sponsor = 'UNAVAILABLE',
  String $site_info_site_policy = 'UNAVAILABLE',
  String $site_info_contact = 'UNAVAILABLE',
  String $site_info_email = 'UNAVAILABLE',
  String $site_info_city = 'UNAVAILABLE',
  String $site_info_country = 'UNAVAILABLE',
  String $site_info_longitude = 'UNAVAILABLE',
  String $site_info_latitude = 'UNAVAILABLE',
  Optional[String] $squid_location = undef,
  Boolean $purge_local_site_settings = true,
  Boolean $purge_gip_config = true,
) inherits osg::params {

  $repo_development_baseurl_bit_real  = pick($repo_development_baseurl_bit, $repo_baseurl_bit)
  $repo_testing_baseurl_bit_real      = pick($repo_testing_baseurl_bit, $repo_baseurl_bit)
  $repo_upcoming_baseurl_bit_real     = pick($repo_upcoming_baseurl_bit, $repo_baseurl_bit)
  $_repo_gpgkey                       = pick($repo_gpgkey, 'https://repo.opensciencegrid.org/osg/RPM-GPG-KEY-OSG')

  anchor { 'osg::start': }
  anchor { 'osg::end': }

  if $manage_epel {
    contain ::epel
  }
  contain osg::repos

  Anchor['osg::start']
  -> Class['osg::repos']
  -> Anchor['osg::end']

  include osg::configure

  # Avoid collecting resources intended for export
  Osg_local_site_settings<| tag != $exported_resources_export_tag |> ~> Exec['osg-configure']
  Osg_gip_config <| |> ~> Exec['osg-configure']

  resources { 'osg_local_site_settings':
    purge  => $purge_local_site_settings,
    notify => Exec['osg-configure'],
  }

  resources { 'osg_gip_config':
    purge  => $purge_gip_config,
    notify => Exec['osg-configure'],
  }

}
