# == Class: osg::gums::client
#
# Installs and configures a GUMS client for use with OSG.
#
class osg::gums::client {

  include osg

  #TODO: Move to osg::configure class
  package { 'osg-configure-misc':
    ensure  => 'present',
    before  => Osg_local_site_settings['Misc Services/gums_host'],
    require => Yumrepo['osg'],
  }

  osg_local_site_settings { 'Misc Services/gums_host':
    value   => $osg::_gums_host,
  }

  service { 'gums-client-cron':
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Osg_local_site_settings['Misc Services/gums_host'],
  }

}
