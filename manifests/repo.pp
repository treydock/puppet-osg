# == Class: osg::repo
#
# Full description of class osg::repo here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if it
#   has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should not be used in preference to class parameters  as of
#   Puppet 2.${::os_maj_version}.)
#
# === Examples
#
#  class { osg::repo: }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2013 Your name here, unless otherwise noted.
#
class osg::repo (
  $baseurl        = $osg::baseurl,
  $mirrorlist     = $osg::mirrorlist
) inherits osg {

  include epel

  ensure_packages(['yum-plugin-priorities'])

  $baseurl_real = $baseurl ? {
    'UNSET' => undef,
    default => $baseurl,
  }
  $mirrorlist_real = $mirrorlist ? {
    false         => undef,
    /false|undef/ => undef,
    default       => $mirrorlist,
  }

  file { '/etc/pki/rpm-gpg/RPM-GPG-KEY-OSG':
    ensure  => present,
    source  => 'puppet:///modules/osg/RPM-GPG-KEY-OSG',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    before  => Yumrepo['osg'],
  }

  yumrepo { 'osg':
    baseurl         => $baseurl_real,
    mirrorlist      => $mirrorlist_real,
    descr           => "OSG Software for Enterprise Linux ${::os_maj_version} - ${::architecture}",
    enabled         => '1',
    failovermethod  => 'priority',
    gpgcheck        => '1',
    gpgkey          => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-OSG',
    priority        => '98',
  }
/*
  yumrepo { 'osg-contrib':
    descr          => "OSG Software for Enterprise Linux ${::os_maj_version} - Contributed - ${::architecture} ",
    enabled        => '0',
    failovermethod => 'priority',
    gpgcheck       => '1',
    gpgkey         => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-OSG',
    mirrorlist     => "http://repo.grid.iu.edu/mirror/3.0/el${::os_maj_version}/osg-contrib/${::architecture}",
    priority       => '98',
  }
  yumrepo { 'osg-contrib-debug':
    baseurl        => "http://repo.grid.iu.edu/3.0/el${::os_maj_version}/osg-contrib/${::architecture}/debug",
    descr          => "OSG Software for Enterprise Linux ${::os_maj_version} - Contributed - ${::architecture} - Debug",
    enabled        => '0',
    failovermethod => 'priority',
    gpgcheck       => '1',
    gpgkey         => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-OSG',
    priority       => '98',
  }
  yumrepo { 'osg-contrib-source':
    baseurl        => "http://repo.grid.iu.edu/3.0/el${::os_maj_version}/osg-contrib/source/SRPMS",
    descr          => "OSG Software for Enterprise Linux ${::os_maj_version} - Contributed - ${::architecture} - Source",
    enabled        => '0',
    failovermethod => 'priority',
    gpgcheck       => '1',
    gpgkey         => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-OSG',
    priority       => '98',
  }
  yumrepo { 'osg-debug':
    baseurl        => "http://repo.grid.iu.edu/3.0/el${::os_maj_version}/osg-release/${::architecture}/debug",
    descr          => "OSG Software for Enterprise Linux ${::os_maj_version} - ${::architecture} - Debug",
    enabled        => '0',
    failovermethod => 'priority',
    gpgcheck       => '1',
    gpgkey         => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-OSG',
    priority       => '98',
  }
  yumrepo { 'osg-development':
    descr          => "OSG Software for Enterprise Linux ${::os_maj_version} - Development - ${::architecture} ",
    enabled        => '0',
    failovermethod => 'priority',
    gpgcheck       => '1',
    gpgkey         => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-OSG',
    mirrorlist     => "http://repo.grid.iu.edu/mirror/3.0/el${::os_maj_version}/osg-development/${::architecture}",
    priority       => '98',
  }
  yumrepo { 'osg-development-debug':
    baseurl        => "http://repo.grid.iu.edu/3.0/el${::os_maj_version}/osg-development/${::architecture}/debug",
    descr          => "OSG Software for Enterprise Linux ${::os_maj_version} - Development - ${::architecture} - Debug",
    enabled        => '0',
    failovermethod => 'priority',
    gpgcheck       => '1',
    gpgkey         => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-OSG',
    priority       => '98',
  }
  yumrepo { 'osg-development-source':
    baseurl        => "http://repo.grid.iu.edu/3.0/el${::os_maj_version}/osg-development/source/SRPMS",
    descr          => "OSG Software for Enterprise Linux ${::os_maj_version} - Development - ${::architecture} - Source",
    enabled        => '0',
    failovermethod => 'priority',
    gpgcheck       => '1',
    gpgkey         => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-OSG',
    priority       => '98',
  }
  yumrepo { 'osg-minefield':
    baseurl        => "http://koji-hub.batlab.org/mnt/koji/repos/el${::os_maj_version}-osg-development/latest/${::architecture}/",
    descr          => "OSG Software for Enterprise Linux ${::os_maj_version} - Build Repository - ${::architecture} ",
    enabled        => '0',
    failovermethod => 'priority',
    gpgcheck       => '1',
    gpgkey         => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-OSG',
    priority       => '98',
  }
  yumrepo { 'osg-prerelease':
    baseurl        => "http://koji-hub.batlab.org/mnt/koji/repos/el${::os_maj_version}-osg-prerelease/latest/${::architecture}/",
    descr          => "OSG Software for Enterprise Linux ${::os_maj_version} - Prerelease Repository for Internal Use - ${::architecture} ",
    enabled        => '0',
    failovermethod => 'priority',
    gpgcheck       => '1',
    gpgkey         => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-OSG',
    priority       => '98',
  }
  yumrepo { 'osg-source':
    baseurl        => "http://repo.grid.iu.edu/3.0/el${::os_maj_version}/osg-release/source/SRPMS",
    descr          => "OSG Software for Enterprise Linux ${::os_maj_version} - ${::architecture} - Source",
    enabled        => '0',
    failovermethod => 'priority',
    gpgcheck       => '1',
    gpgkey         => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-OSG',
    priority       => '98',
  }
  yumrepo { 'osg-testing':
    descr          => "OSG Software for Enterprise Linux ${::os_maj_version} - Testing - ${::architecture} ",
    enabled        => '0',
    failovermethod => 'priority',
    gpgcheck       => '1',
    gpgkey         => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-OSG',
    mirrorlist     => "http://repo.grid.iu.edu/mirror/3.0/el${::os_maj_version}/osg-testing/${::architecture}",
    priority       => '98',
  }
  yumrepo { 'osg-testing-debug':
    baseurl        => "http://repo.grid.iu.edu/3.0/el${::os_maj_version}/osg-testing/${::architecture}/debug",
    descr          => "OSG Software for Enterprise Linux ${::os_maj_version} - Testing - ${::architecture} - Debug",
    enabled        => '0',
    failovermethod => 'priority',
    gpgcheck       => '1',
    gpgkey         => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-OSG',
    priority       => '98',
  }
  yumrepo { 'osg-testing-source':
    baseurl        => "http://repo.grid.iu.edu/3.0/el${::os_maj_version}/osg-testing/source/SRPMS",
    descr          => "OSG Software for Enterprise Linux ${::os_maj_version} - Testing - ${::architecture} - Source",
    enabled        => '0',
    failovermethod => 'priority',
    gpgcheck       => '1',
    gpgkey         => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-OSG',
    priority       => '98',
  }
  yumrepo { 'osg-upcoming':
    descr          => "OSG Software for Enterprise Linux ${::os_maj_version} - Upcoming - ${::architecture}",
    enabled        => '0',
    failovermethod => 'priority',
    gpgcheck       => '1',
    gpgkey         => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-OSG',
    mirrorlist     => "http://repo.grid.iu.edu/mirror/3.0/el${::os_maj_version}/osg-upcoming-release/${::architecture}",
    priority       => '98',
  }
  yumrepo { 'osg-upcoming-debug':
    baseurl        => "http://repo.grid.iu.edu/3.0/el${::os_maj_version}/osg-upcoming-release/${::architecture}/debug",
    descr          => "OSG Software for Enterprise Linux ${::os_maj_version} - Upcoming - ${::architecture} - Debug",
    enabled        => '0',
    failovermethod => 'priority',
    gpgcheck       => '1',
    gpgkey         => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-OSG',
    priority       => '98',
  }
  yumrepo { 'osg-upcoming-development':
    descr          => "OSG Software for Enterprise Linux ${::os_maj_version} - Upcoming Development - ${::architecture} ",
    enabled        => '0',
    failovermethod => 'priority',
    gpgcheck       => '1',
    gpgkey         => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-OSG',
    mirrorlist     => "http://repo.grid.iu.edu/mirror/3.0/el${::os_maj_version}/osg-upcoming-development/${::architecture}",
    priority       => '98',
  }
  yumrepo { 'osg-upcoming-development-debug':
    baseurl        => "http://repo.grid.iu.edu/3.0/el${::os_maj_version}/osg-upcoming-development/${::architecture}/debug",
    descr          => "OSG Software for Enterprise Linux ${::os_maj_version} - Upcoming Development - ${::architecture} - Debug",
    enabled        => '0',
    failovermethod => 'priority',
    gpgcheck       => '1',
    gpgkey         => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-OSG',
    priority       => '98',
  }
  yumrepo { 'osg-upcoming-development-source':
    baseurl        => "http://repo.grid.iu.edu/3.0/el${::os_maj_version}/osg-upcoming-development/source/SRPMS",
    descr          => "OSG Software for Enterprise Linux ${::os_maj_version} - Upcoming Development - ${::architecture} - Source",
    enabled        => '0',
    failovermethod => 'priority',
    gpgcheck       => '1',
    gpgkey         => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-OSG',
    priority       => '98',
  }
  yumrepo { 'osg-upcoming-minefield':
    baseurl        => "http://koji-hub.batlab.org/mnt/koji/repos/el${::os_maj_version}-osg-upcoming-development/latest/${::architecture}/",
    descr          => "OSG Software for Enterprise Linux ${::os_maj_version} - Upcoming Build Repository - ${::architecture} ",
    enabled        => '0',
    failovermethod => 'priority',
    gpgcheck       => '1',
    gpgkey         => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-OSG',
    priority       => '98',
  }
  yumrepo { 'osg-upcoming-prerelease':
    baseurl        => "http://koji-hub.batlab.org/mnt/koji/repos/el${::os_maj_version}-osg-upcoming-prerelease/latest/${::architecture}/",
    descr          => "OSG Software for Enterprise Linux ${::os_maj_version} - Upcoming Prerelease Repository for Internal Use - ${::architecture} ",
    enabled        => '0',
    failovermethod => 'priority',
    gpgcheck       => '1',
    gpgkey         => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-OSG',
    priority       => '98',
  }
  yumrepo { 'osg-upcoming-source':
    baseurl        => "http://repo.grid.iu.edu/3.0/el${::os_maj_version}/osg-upcoming-release/source/SRPMS",
    descr          => "OSG Software for Enterprise Linux ${::os_maj_version} - Upcoming - ${::architecture} - Source",
    enabled        => '0',
    failovermethod => 'priority',
    gpgcheck       => '1',
    gpgkey         => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-OSG',
    priority       => '98',
  }
  yumrepo { 'osg-upcoming-testing':
    descr          => "OSG Software for Enterprise Linux ${::os_maj_version} - Upcoming Testing - ${::architecture} ",
    enabled        => '0',
    failovermethod => 'priority',
    gpgcheck       => '1',
    gpgkey         => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-OSG',
    mirrorlist     => "http://repo.grid.iu.edu/mirror/3.0/el${::os_maj_version}/osg-upcoming-testing/${::architecture}",
    priority       => '98',
  }
  yumrepo { 'osg-upcoming-testing-debug':
    baseurl        => "http://repo.grid.iu.edu/3.0/el${::os_maj_version}/osg-upcoming-testing/${::architecture}/debug",
    descr          => "OSG Software for Enterprise Linux ${::os_maj_version} - Upcoming Testing - ${::architecture} - Debug",
    enabled        => '0',
    failovermethod => 'priority',
    gpgcheck       => '1',
    gpgkey         => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-OSG',
    priority       => '98',
  }
  yumrepo { 'osg-upcoming-testing-source':
    baseurl        => "http://repo.grid.iu.edu/3.0/el${::os_maj_version}/osg-upcoming-testing/source/SRPMS",
    descr          => "OSG Software for Enterprise Linux ${::os_maj_version} - Upcoming Testing - ${::architecture} - Source",
    enabled        => '0',
    failovermethod => 'priority',
    gpgcheck       => '1',
    gpgkey         => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-OSG',
    priority       => '98',
  }
*/
}
