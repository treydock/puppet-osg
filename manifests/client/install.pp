# @summary Install OSG client
# @api private
class osg::client::install {

  if $osg::client::with_condor {
    package { 'condor':
      ensure => 'present',
    }

    if $osg::client::with_condor_ce {
      Package['condor'] -> Package['htcondor-ce']
    }
  }

  if $osg::client::with_condor_ce {
    package { 'htcondor-ce':
      ensure => 'present',
    }
  }

}
