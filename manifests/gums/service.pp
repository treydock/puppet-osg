# Private class: See README.md.
class osg::gums::service {

  if $osg::gums::manage_tomcat {
    service { $osg::gums::tomcat_service:
      ensure     => 'running',
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
    }
  }

}
