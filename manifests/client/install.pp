# Private class: See README.md.
class osg::client::install {

  if $osg::client::with_condor {
    package { 'condor':
      ensure => 'present',
      before => Package['htcondor-ce'],
    }
  }

  if $osg::client::with_condor_ce {
    package { 'htcondor-ce':
      ensure => 'present',
    }
  }

}
