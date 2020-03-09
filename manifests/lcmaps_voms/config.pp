# @summary Manage lcmaps voms configs
# @api private
class osg::lcmaps_voms::config {

  osg_local_site_settings { 'Misc Services/authorization_method':
    value => 'vomsmap',
  }
  osg_local_site_settings { 'Misc Services/edit_lcmaps_db':
    value => true,
  }
  osg_local_site_settings { 'Misc Services/gums_host':
    ensure => 'absent',
    value  => 'DEFAULT',
  }

  concat { '/etc/grid-security/voms-mapfile':
    ensure => 'present',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    warn   => true,
  }

  concat { '/etc/grid-security/grid-mapfile':
    ensure => 'present',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    warn   => true,
  }

  file { '/etc/grid-security/ban-voms-mapfile':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('osg/lcmaps_voms/ban-voms-mapfile.erb')
  }

  file { '/etc/grid-security/ban-mapfile':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('osg/lcmaps_voms/ban-mapfile.erb')
  }

}
