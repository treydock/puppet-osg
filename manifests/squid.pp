# @summary Manage OSG squid
#
# @param customize_template
#   Path to template used to customize squid
# @param net_local
#   Local networks
# @param monitor_addresses
#   Monitor addresses
# @param allow_major_cvmfs
#   Enables and allows `MAJOR_CVMFS`
# @param max_filedescriptors
#   Sets `max_filedescriptors`
# @param manage_firewall
#   Manage firewall resources
# @param squid_firewall_ensure
#   Ensure property for squid firewall
# @param monitoring_firewall_ensure
#   Ensure property for monitoring firewall
# @param private_interface
#   Private interface, used by firewall rules to allow squid access
# @param public_interface
#   Public interface, used by firewall rules to allow monitor addresses
#
class osg::squid (
  String $customize_template = 'osg/squid/customize.sh.erb',
  Array $net_local = ['10.0.0.0/8', '172.16.0.0/12', '192.168.0.0/16'],
  Array $monitor_addresses = ['128.142.0.0/16', '188.184.128.0/17', '188.185.128.0/17'],
  Boolean $allow_major_cvmfs = true,
  Integer $max_filedescriptors = 0,
  Boolean $manage_firewall = true,
  Enum['present', 'absent'] $squid_firewall_ensure = 'present',
  Enum['present', 'absent'] $monitoring_firewall_ensure = 'present',
  Optional[String] $private_interface = undef,
  Optional[String] $public_interface = undef,
) {

  include osg

  $squid_location = pick($osg::squid_location, $::fqdn)

  if $manage_firewall {
    firewall { '100 allow squid access':
      ensure  => $squid_firewall_ensure,
      dport   => '3128',
      proto   => 'tcp',
      iniface => $private_interface,
      action  => 'accept',
    }
    $monitor_addresses.each |$monitor_address| {
      firewall { "101 allow squid monitoring from ${monitor_address}":
        ensure  => $monitoring_firewall_ensure,
        dport   => '3401',
        proto   => 'udp',
        source  => $monitor_address,
        iniface => $public_interface,
        action  => 'accept',
      }
    }
  }

  package { 'frontier-squid':
    ensure  => 'present',
    require => Yumrepo['osg'],
    before  => File['/etc/squid/customize.sh'],
  }

  file { '/etc/squid/customize.sh':
    ensure  => 'file',
    owner   => 'squid',
    group   => 'squid',
    mode    => '0755',
    content => template($customize_template),
  }

  service { 'frontier-squid':
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    subscribe  => File['/etc/squid/customize.sh'],
  }

  if $osg::enable_exported_resources {
    @@osg_local_site_settings { 'Squid/enabled':
      value => true,
      tag   => $osg::exported_resources_export_tag,
    }

    @@osg_local_site_settings { 'Squid/location':
      value => $squid_location,
      tag   => $osg::exported_resources_export_tag,
    }
  }

}
