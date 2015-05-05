# Private class: See README.md.
class osg::client::service {

  include osg::client

  if $osg::client::enable_condor_service {
    $condor_ensure = 'running'
    $condor_enable = true
  } else {
    $condor_ensure = 'stopped'
    $condor_enable = false
  }

  if $osg::client::enable_condor_ce_service {
    $condor_ce_ensure = 'running'
    $condor_ce_enable = true
  } else {
    $condor_ce_ensure = 'stopped'
    $condor_ce_enable = false
  }

  if $osg::client::with_condor {
    service { 'condor':
      ensure     => $condor_ensure,
      enable     => $condor_enable,
      hasstatus  => true,
      hasrestart => true,
    }

    service { 'condor-ce':
      ensure     => $condor_ce_ensure,
      enable     => $condor_ce_enable,
      hasstatus  => true,
      hasrestart => true,
    }
  }

}
