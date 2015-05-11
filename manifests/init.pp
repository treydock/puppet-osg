# Class: osg: See README.md for documentation.
class osg (
  $osg_release                    = '3.2',
  $repo_baseurl_bit               = 'http://repo.grid.iu.edu',
  $repo_development_baseurl_bit   = undef,
  $repo_testing_baseurl_bit       = undef,
  $repo_upcoming_baseurl_bit      = undef,
  $repo_use_mirrors               = true,
  $repo_gpgkey                    = 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-OSG',
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
) inherits osg::params {

  validate_re($osg_release, '^(3.1|3.2)$', 'The osg_release parameter only supports 3.1 and 3.2')
  validate_re($cacerts_package_name, '^(osg-ca-certs|igtf-ca-certs|empty-ca-certs)$')
  validate_bool($repo_use_mirrors)
  validate_bool($enable_osg_contrib)
  validate_bool($cacerts_install_other_packages)

  $repo_development_baseurl_bit_real  = pick($repo_development_baseurl_bit, $repo_baseurl_bit)
  $repo_testing_baseurl_bit_real      = pick($repo_testing_baseurl_bit, $repo_baseurl_bit)
  $repo_upcoming_baseurl_bit_real     = pick($repo_upcoming_baseurl_bit, $repo_baseurl_bit)
  $_gums_host                         = pick($gums_host, "gums.${::domain}")

  anchor { 'osg::start': }
  anchor { 'osg::end': }

  include epel
  include osg::repos

  Anchor['osg::start']->
  Class['epel']->
  Class['osg::repos']->
  Anchor['osg::end']

  include osg::configure

  Osg_local_site_settings<| |> ~> Exec['osg-configure']

}
