# == Class: osg::client::config
#
class osg::client::config {

  include osg
  include osg::client

  $globus_tcp_port_range_min    = $osg::globus_tcp_port_range_min
  $globus_tcp_port_range_max    = $osg::globus_tcp_port_range_max
  $globus_tcp_source_range_min  = $osg::globus_tcp_source_range_min
  $globus_tcp_source_range_max  = $osg::globus_tcp_source_range_max
  $condor_lowport               = $osg::condor_lowport
  $condor_highport              = $osg::condor_highport

  file { '/etc/profile.d/globus_firewall.sh':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('osg/client/globus_firewall.sh.erb'),
  }

  file { '/etc/profile.d/globus_firewall.csh':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('osg/client/globus_firewall.csh.erb'),
  }

  if $osg::client::with_condor {
    file { '/etc/condor/config.d/10firewall_condor.config':
      ensure  => 'file',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('osg/client/10firewall_condor.config.erb'),
      notify  => Service['condor'],
    }

    file_line { 'condor DAEMON_LIST':
      path    => '/etc/condor/config.d/00personal_condor.config',
      line    => 'DAEMON_LIST = COLLECTOR, MASTER, NEGOTIATOR, SCHEDD',
      match   => '^DAEMON_LIST.*',
      notify  => Service['condor'],
    }
  }

}
