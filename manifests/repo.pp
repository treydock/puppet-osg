# == Class: osg::repo
#
# Adds the OSG yum repo
#
# === Parameters
#
# [*baseurl*]
#   The baseurl used for the OSG yum repo.
#   Default: undef
#
# [*mirrorlist*]
#   The mirrorlist used for the OSG yum repo.
#   Set to false to disable this line in the yum repo.
#
# === Examples
#
#  class { 'osg::repo': }
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2013 Trey Dockendorf
#
class osg::repo (
  $baseurl        = $osg::baseurl,
  $mirrorlist     = $osg::mirrorlist
) inherits osg {

  include epel
  include osg::params

  Class['epel'] -> Class['osg::repo']

  ensure_packages($osg::params::repo_dependencies)

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
    require         => Yumrepo['epel'],
  }
}
