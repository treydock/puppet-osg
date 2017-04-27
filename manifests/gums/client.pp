# Private class: See README.md.
class osg::gums::client {

  include osg

  package { 'gums-client':
    ensure  => 'present',
    require => Yumrepo['osg'],
    before  => Service['gums-client-cron'],
  }

  #TODO: Move to osg::configure class
  package { 'osg-configure-misc':
    ensure  => 'present',
    before  => Osg_local_site_settings['Misc Services/gums_host'],
    require => Yumrepo['osg'],
  }

  osg_local_site_settings { 'Misc Services/authorization_method':
    value => 'xacml',
  }
  osg_local_site_settings { 'Misc Services/gums_host':
    value => $osg::_gums_host,
  }

  service { 'gums-client-cron':
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    provider   => 'redhat',
    require    => Osg_local_site_settings['Misc Services/gums_host'],
  }

}
