# == Class: osg::repo
#
# Adds the OSG yum repo
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2013 Trey Dockendorf
#
class osg::repo {

  include epel
  include osg
  include osg::params

  Class['epel'] -> Class['osg::repo']

  $yum_priorities_package = $osg::params::yum_priorities_package

  $baseurl = $osg::baseurl_real ? {
    'UNSET' => undef,
    default => $osg::baseurl_real,
  }
  $mirrorlist = $osg::mirrorlist_real ? {
    false         => undef,
    /false|undef/ => undef,
    default       => $osg::mirrorlist_real,
  }

  ensure_packages([$yum_priorities_package])

  file { '/etc/pki/rpm-gpg/RPM-GPG-KEY-OSG':
    ensure  => present,
    source  => 'puppet:///modules/osg/RPM-GPG-KEY-OSG',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  gpg_key { 'osg':
    path    => '/etc/pki/rpm-gpg/RPM-GPG-KEY-OSG',
    before  => Yumrepo['osg'],
  }

  #TODO : Need consider_as_osg=yes
  yumrepo { 'osg':
    baseurl         => $baseurl,
    mirrorlist      => $mirrorlist,
    descr           => "OSG Software for Enterprise Linux ${::os_maj_version} - ${::architecture}",
    enabled         => '1',
    failovermethod  => 'priority',
    gpgcheck        => '1',
    gpgkey          => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-OSG',
    priority        => '98',
    require         => [Package[$yum_priorities_package], Yumrepo['epel']],
  }
}
