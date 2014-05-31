# == Class: osg::gums::client
#
# Installs and configures a GUMS client for use with OSG.
#
class osg::gums::client {

  include osg

  package { 'osg-configure-misc':
    ensure  => 'present',
    before  => Osg_config['Misc Services/gums_host'],
    require => Yumrepo['osg'],
  }

  osg_config { 'Misc Services/gums_host':
    value   => $osg::gums_host,
    path    => '10-misc.ini',
  }

  service { 'gums-client-cron':
    ensure      => 'running',
    enable      => true,
    hasstatus   => true,
    hasrestart  => true,
    require     => Osg_config['Misc Services/gums_host'],
  }

}
