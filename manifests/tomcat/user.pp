# Private class: See README.md.
class osg::tomcat::user inherits osg::params {
  user { 'tomcat':
    ensure     => 'present',
    comment    => 'Apache Tomcat',
    forcelocal => true,
    gid        => 'tomcat',
    home       => $osg::params::tomcat_base_dir,
    managehome => false,
    shell      => '/sbin/nologin',
    system     => true,
    uid        => '91'
  }

  group { 'tomcat':
    ensure => 'present',
    gid    => '91',
    system => true,
  }
}
