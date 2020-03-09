# @summary Manage OSG repos
# @api private
class osg::repos {

  include osg
  include osg::params

  if $osg::repo_use_mirrors {
    $baseurls   = {
      'osg'                       => 'absent',
      'osg-empty'                 => 'absent',
      'osg-contrib'               => 'absent',
      'osg-development'           => 'absent',
      'osg-testing'               => 'absent',
      'osg-upcoming'              => 'absent',
      'osg-upcoming-development'  => 'absent',
      'osg-upcoming-testing'      => 'absent',
    }

    $mirrorlists = {
      'osg'                       => "https://repo.opensciencegrid.org/mirror/osg/${osg::osg_release}/el${::operatingsystemmajrelease}/release/${::architecture}",
      'osg-empty'                 => "https://repo.opensciencegrid.org/mirror/osg/${osg::osg_release}/el${::operatingsystemmajrelease}/empty/${::architecture}",
      'osg-contrib'               => "https://repo.opensciencegrid.org/mirror/osg/${osg::osg_release}/el${::operatingsystemmajrelease}/contrib/${::architecture}",
      'osg-development'           => "https://repo.opensciencegrid.org/mirror/osg/${osg::osg_release}/el${::operatingsystemmajrelease}/development/${::architecture}",
      'osg-testing'               => "https://repo.opensciencegrid.org/mirror/osg/${osg::osg_release}/el${::operatingsystemmajrelease}/testing/${::architecture}",
      'osg-upcoming'              => "https://repo.opensciencegrid.org/mirror/osg/upcoming/el${::operatingsystemmajrelease}/release/${::architecture}",
      'osg-upcoming-development'  => "https://repo.opensciencegrid.org/mirror/osg/upcoming/el${::operatingsystemmajrelease}/development/${::architecture}",
      'osg-upcoming-testing'      => "https://repo.opensciencegrid.org/mirror/osg/upcoming/el${::operatingsystemmajrelease}/testing/${::architecture}",
    }
  } else {
    $baseurls   = {
      'osg'                       => "${osg::repo_baseurl_bit}/osg/${osg::osg_release}/el${::operatingsystemmajrelease}/release/${::architecture}",
      'osg-empty'                 => "${osg::repo_baseurl_bit}/osg/${osg::osg_release}/el${::operatingsystemmajrelease}/empty/${::architecture}",
      'osg-contrib'               => "${osg::repo_baseurl_bit}/osg/${osg::osg_release}/el${::operatingsystemmajrelease}/contrib/${::architecture}",
      'osg-development'           => "${osg::repo_development_baseurl_bit_real}/osg/${osg::osg_release}/el${::operatingsystemmajrelease}/development/${::architecture}",
      'osg-testing'               => "${osg::repo_testing_baseurl_bit_real}/osg/${osg::osg_release}/el${::operatingsystemmajrelease}/testing/${::architecture}",
      'osg-upcoming'              => "${osg::repo_upcoming_baseurl_bit_real}/osg/upcoming/el${::operatingsystemmajrelease}/release/${::architecture}",
      'osg-upcoming-development'  => "${osg::repo_upcoming_baseurl_bit_real}/osg/upcoming/el${::operatingsystemmajrelease}/development/${::architecture}",
      'osg-upcoming-testing'      => "${osg::repo_upcoming_baseurl_bit_real}/osg/upcoming/el${::operatingsystemmajrelease}/testing/${::architecture}",
    }

    $mirrorlists = {
      'osg'                       => 'absent',
      'osg-empty'                 => 'absent',
      'osg-contrib'               => 'absent',
      'osg-development'           => 'absent',
      'osg-testing'               => 'absent',
      'osg-upcoming'              => 'absent',
      'osg-upcoming-development'  => 'absent',
      'osg-upcoming-testing'      => 'absent',
    }
  }

  ensure_packages([$osg::params::yum_priorities_package])

  Yumrepo {
    failovermethod  => 'priority',
    gpgcheck        => '1',
    gpgkey          => $osg::_repo_gpgkey,
    priority        => '98',
  }

  #TODO : Need consider_as_osg=yes
  yumrepo { 'osg':
    baseurl    => $baseurls['osg'],
    mirrorlist => $mirrorlists['osg'],
    descr      => "OSG Software for Enterprise Linux ${::operatingsystemmajrelease} - ${::architecture}",
    enabled    => bool2num($osg::enable_osg),
  }

  yumrepo { 'osg-empty':
    baseurl     => $baseurls['osg-empty'],
    mirrorlist  => $mirrorlists['osg-empty'],
    descr       => "OSG Software for Enterprise Linux ${::operatingsystemmajrelease} - Empty Packages - ${::architecture}",
    enabled     => bool2num($osg::enable_osg_empty),
    includepkgs => 'empty-ca-certs empty-slurm empty-torque',
  }

  yumrepo { 'osg-contrib':
    baseurl    => $baseurls['osg-contrib'],
    mirrorlist => $mirrorlists['osg-contrib'],
    descr      => "OSG Software for Enterprise Linux ${::operatingsystemmajrelease} - Contributed - ${::architecture}",
    enabled    => bool2num($osg::enable_osg_contrib),
  }

  yumrepo { 'osg-development':
    baseurl    => $baseurls['osg-development'],
    mirrorlist => $mirrorlists['osg-development'],
    descr      => "OSG Software for Enterprise Linux ${::operatingsystemmajrelease} - Development - ${::architecture}",
    enabled    => '0',
  }

  yumrepo { 'osg-testing':
    baseurl    => $baseurls['osg-testing'],
    mirrorlist => $mirrorlists['osg-testing'],
    descr      => "OSG Software for Enterprise Linux ${::operatingsystemmajrelease} - Testing - ${::architecture}",
    enabled    => '0',
  }

  yumrepo { 'osg-upcoming':
    baseurl    => $baseurls['osg-upcoming'],
    mirrorlist => $mirrorlists['osg-upcoming'],
    descr      => "OSG Software for Enterprise Linux ${::operatingsystemmajrelease} - Upcoming - ${::architecture}",
    enabled    => '0',
  }

  yumrepo { 'osg-upcoming-development':
    baseurl    => $baseurls['osg-upcoming-development'],
    mirrorlist => $mirrorlists['osg-upcoming-development'],
    descr      => "OSG Software for Enterprise Linux ${::operatingsystemmajrelease} - Upcoming Development - ${::architecture}",
    enabled    => '0',
  }

  yumrepo { 'osg-upcoming-testing':
    baseurl    => $baseurls['osg-upcoming-testing'],
    mirrorlist => $mirrorlists['osg-upcoming-testing'],
    descr      => "OSG Software for Enterprise Linux ${::operatingsystemmajrelease} - Upcoming Testing - ${::architecture}",
    enabled    => '0',
  }

}
