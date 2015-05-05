# == Class: osg::client::install
#
class osg::client::install {

  include osg::client

  if $osg::client::with_condor {
    if $osg::client::with_condor_ce {
      $_condor_before = Package['htcondor-ce']
    } else {
      $_condor_before = Package['osg-client']
    }

    package { 'condor':
      ensure => 'present',
      before => $_condor_before,
    }
  }

  if $osg::client::with_condor_ce {
    package { 'htcondor-ce':
      ensure => 'present',
      before => Package['osg-client'],
    }
  }

  package { 'osg-client':
    ensure  => 'present',
  }

}
