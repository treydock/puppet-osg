# == Class: osg::client::install
#
class osg::client::install {

  include osg::client

  package { 'osg-client':
    ensure  => 'present',
  }

  if $osg::client::with_condor {
    package { 'condor':
      ensure  => 'present',
    }
  }

  if $osg::client::with_condor_ce {
    package { 'htcondor-ce':
      ensure  => 'present',
    }
  }

}
