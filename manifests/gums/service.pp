# == Class: osg::gums::service
#
class osg::gums::service {

  include ::osg::gums

  if $::osg::gums::manage_tomcat {
    service { 'tomcat6':
      ensure      => 'running',
      enable      => true,
      hasstatus   => true,
      hasrestart  => true,
    }
  }

}
