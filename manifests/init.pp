# @summary Class for common OSG parameters and common resources
#
# @param osg_release
#   OSG release
# @param repo_baseurl_bit
#   Base URL for osg repo, eg: `https://repo.opensciencegrid.org`
# @param repo_development_baseurl_bit
#   Base URL for osg-development repo, default: `https://repo.opensciencegrid.org`
# @param repo_testing_baseurl_bit
#   Base URL for osg-testubg repo, default: `https://repo.opensciencegrid.org`
# @param repo_upcoming_baseurl_bit
#   Base URL for osg-upcoming repo, default: `https://repo.opensciencegrid.org`
# @param repo_use_mirrors
#   Sets if repos should use mirrors
# @param repo_gpgkey
#   Path to repo GPG key
# @param enable_osg
#   Enable the osg repo
# @param enable_osg_empty
#   Enable the osg-empty repo
# @param enable_osg_contrib
#   Enable the osg-contrib repo
# @param manage_epel
#   Manage the EPEL repo
# @param auth_type
#   Grid authentication type
# @param cacerts_package_name
#   Package name for osg-ca-certs
# @param cacerts_install_other_packages
#   TODO Remove
# @param cacerts_package_ensure
#   CA certs package ensure
# @param cacerts_other_packages_ensure
#   TODO Remove
# @param shared_certs_path
#   Path to location of shared certs, for example if storing certs on NFS
# @param globus_tcp_port_range_min
#   Min for GLOBUS_TCP_PORT_RANGE
# @param globus_tcp_port_range_max
#   Max for GLOBUS_TCP_PORT_RANGE
# @param globus_tcp_source_range_min
#   Min for GLOBUS_TCP_SOURCE_RANGE
# @param globus_tcp_source_range_max
#   Max for GLOBUS_TCP_SOURCE_RANGE
# @param condor_lowport
#   TODO Move to client
# @param condor_highport
#   TODO Move to client
# @param condor_schedd_host
#   TODO Move to client
# @param condor_collector_host
#   TODO Move to client
# @param enable_exported_resources
#   Enable exported resources, useful when services like Squid and CE live on different hosts
# @param exported_resources_export_tag
#   Exported resources export tag
# @param exported_resource_collect_tag
#   Exported resources collect tag
# @param site_info_group
#   osg-configure Site Information/group
# @param site_info_host_name
#   osg-configure Site Information/host_name
# @param site_info_resource
#   osg-configure Site Information/resource
# @param site_info_resource_group
#   osg-configure Site Information/resource_group
# @param site_info_sponsor
#   osg-configure Site Information/sponsor
# @param site_info_site_policy
#   osg-configure Site Information/site_policy
# @param site_info_contact
#   osg-configure Site Information/contact
# @param site_info_email
#   osg-configure Site Information/email
# @param site_info_city
#   osg-configure Site Information/city
# @param site_info_country
#   osg-configure Site Information/country
# @param site_info_longitude
#   osg-configure Site Information/longitude
# @param site_info_latitude
#   osg-configure Site Information/latitude
# @param squid_location
#   osg-confgiure Squid/location
# @param purge_local_site_settings
#   Purge unmanaged osg_local_site_settings resources
# @param purge_gip_config
#   Purge unmanaged osg_gip_config
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
