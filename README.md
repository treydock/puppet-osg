# puppet-osg

[![Puppet Forge](http://img.shields.io/puppetforge/v/treydock/osg.svg)](https://forge.puppetlabs.com/treydock/osg)
[![Build Status](https://travis-ci.org/treydock/puppet-osg.svg?branch=master)](https://travis-ci.org/treydock/puppet-osg)

#### Table of Contents

1. [Overview](#overview)
1. [Usage - Configuration examples and options](#usage)
1. [Reference - Parameter and detailed reference to all options](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for testing and contributing to the module](#development)

## Overview

The OSG module manages the various components that make up the [Open Science Grid](https://opensciencegrid.org/docs/) software stack.

### OSG Compatibility

**Currently this module supports OSG 3.5.**

The current version support matrix is as follows:

OSG Versions       |  3.3 |  3.4 | 3.5 |
:------------------|:----:|:----:|:---:|
**puppet-osg 1.x** | yes  | no   | no  |
**puppet-osg 2.x** | yes  | yes  | no  |
**puppet-osg 3.x** | yes  | yes  | no  |
**puppet-osg 4.x** | no   | yes  | no  |
**puppet-osg 5.x** | no   | no   | yes |

## Usage

### Classes

The public classes of this module are split into "roles".  For example a CE would use the class `osg::ce`.

#### osg

The OSG class is required by all the other classes.  This class sets parameters that are used by multiple "roles" and is the class responsible for configuring the OSG repos.

```puppet
    class { 'osg': }
```

If all systems pull their grid-certificates from a shared filesystem then you instruct this module to install the `empty-ca-certs` package and symlink `/home/osg/grid-certificates` to `/etc/grid-security/certificates`.  If this method is used some script must be executed on a regular basis to sync one system's certificates into the shared location.  Such a script is currently outside the scope of this module.

```puppet
    class { 'osg':
      shared_certs_path     => '/home/osg/grid-certificates',
      cacerts_package_name  => 'empty-ca-certs',
    }
```

The `cacerts_package_ensure` parameter can be used to ensure the latest CA certs package is installed.  This is basically the same functionality as provided by the resources managed under the `osg::cacerts::updater` class.

```puppet
    class { 'osg':
      cacerts_package_name   => 'osg-ca-certs',
      cacerts_package_ensure => 'latest',
    }
```

#### osg::cacerts::updater

The `osg::cacerts::updater` class by default will perform the following actions

* Install `osg-ca-certs-updater` and `fetch-crl` packages
* Configure `/etc/cron.d/osg-ca-certs-updater`
* Start the `osg-ca-certs-updater-cron` service
* Start the `fetch-crl-cron` service
* Stop the `fetch-crl-boot` service

Example usage:

```puppet
    class { 'osg':
      cacerts_package_name => 'osg-ca-certs',
    }
    class { 'osg::cacerts::updater': }
```

This class essentially performs the same role as setting `osg::cacerts_package_ensure` and `osg::cacerts_other_packages_ensure` to `latest`.

#### osg::ce

This class by default configures a HTCondor CE.  The following example is to configure using HTCondor-CE that uses the SLURM batch system.  This example also shows how to setup a host as the system that keeps the shared grid-certificates up-to-date.

```puppet
    class { 'osg':
      site_info_resource        => 'SITE_CE',
      site_info_resource_group  => 'SITE',
      site_info_sponsor         => 'vo-name-here',
      site_info_site_policy     => '',
      site_info_contact         => 'Full Name'
      site_info_email           => 'admin@site.com'
      site_info_city            => 'Somewhere'
      site_info_country         => 'USA'
      site_info_longitude       => '-0.000000'
      site_info_latitude        => '0.000000'
    }
    class { 'osg::ce':
      batch_system              => 'slurm',
      hostcert_source           => 'file:///home/admin/osg/certs/ce/hostcert.pem',
      hostkey_source            => 'file:///home/admin/osg/certs/ce/hostkey.pem',
    }
```

#### osg::client

The `osg::client` class is intended to configure client systems, such as login nodes, to interact with the OSG software.  The example below is a rough idea of how one would configure a client system to send both condor and condor-ce requests to a remote HTCondor-CE instance.

```puppet
    class { 'osg::client'
      condor_schedd_host    => 'ce.example.tld',
      condor_collector_host => 'ce.example.tld:9619',
    }
```

The default behavior is to ensure both condor and htcondor-ce are installed but the services for each are disabled.

#### osg::cvmfs

The `osg::cvmfs` class will install and configure a system to access the CVMFS wide-area filesystem.  The default parameter values should be enough to allow access to the filesystem.

```puppet
    class { 'osg::cvmfs': }
```

Any host that needs to access /cvmfs should have this class assigned.

#### osg::gridftp

The `osg::gridftp` class by default will configure a system as a standalone OSG GridFTP server.  Note that the `osg::ce` classes declares this class with `standalone` set to `false`, so do not include this class if the `osg::ce` class is assigned.

```puppet
    class { 'osg':
      site_info_resource        => 'SITE_GRIDFTP',
      site_info_resource_group  => 'SITE',
      site_info_sponsor         => 'vo-name-here',
      site_info_site_policy     => '',
      site_info_contact         => 'Full Name'
      site_info_email           => 'admin@site.com'
      site_info_city            => 'Somewhere'
      site_info_country         => 'USA'
      site_info_longitude       => '-0.000000'
      site_info_latitude        => '0.000000'
    }
    class { 'osg::gridftp':
      hostcert_source       => 'file:///home/admin/osg/certs/gridftp/hostcert.pem',
      hostkey_source        => 'file:///home/admin/osg/certs/gridftp/hostkey.pem',
    }
```

#### osg::lcmaps_voms

The following example will setup LCMAPS VOMS to authenticate the GLOW VO and ban CMS production.  The `vo` parameter will create `osg::lcmaps_voms::vo` resources and the `users` parameter will create `osg::lcmaps_voms::user` resources.

```puppet
    class { 'osg::lcmaps_voms':
      ban_voms => ['/cms/Role=production/*'],
      ban_users => ['/foo/baz'],
      vos       => {
        'glow' => '/GLOW/*',
        'glow1 => '['/GLOW/chtc/*', '/GLOW/Role=htpc/*'],
      },
      users     => {
        'foo'   => '/fooDN',
        'foobar => ['/foo', '/bar'],
      }
    }
```

#### osg::lcmaps_voms::vo

This defined type populates `/etc/grid-security/voms-mapfile`.  The `dn` value can be an Array or a String.

```puppet
    osg::lcmaps_voms::vo { 'nova':
      dn => '/fermilab/nova/Role=pilot',
    }
```

#### osg::lcmaps_voms::user

This defined type populates `/etc/grid-security/grid-mapfile`.  The `dn` value can be an Array or a String.

```puppet
    osg::lcmaps_voms::user { 'rsv':
      dn => '/DC=org/DC=opensciencegrid/O=Open Science Grid/OU=Services/CN=rsv/ce.example.com',
    }
```

#### osg::squid

The `osg::squid` class will configure a system to run the Frontier Squid service.  The example below installs squid and configures the firewall to allow access to squid on the host's `eth0` private interface and allows squid monitoring on the `eth1` public interface.

```puppet
    class { 'osg::squid':
      private_interface => 'eth0',
      public_interface  => 'eth1',
    }
```

Be sure to define `squid_location` that points to the location of the squid server

```puppet
    class { 'osg':
      squid_location => 'squid.site.com',
    }
```

The `customize_template` can be used to pass a site-specific template used to customize squid.  The template provided by this module is very basic.  The value in the example below will look in the `site_osg` Puppet module under `templates/squid` for the file `customize.sh.erb`.  The value of `customize_template` is passed directly to the Puppet `template` function.

```puppet
    class { 'osg::squid':
      customize_template  => 'site_osg/squid/customize.sh.erb',
    }
```

#### osg::utils

The `osg::utils` class will install utility packages from OSG.

Example:

```puppet
    class { 'osg::utils':}
```

#### osg::wn

The `osg::wn` class will configure a worker node to work with the OSG software.   This class currently has no parameters and performs the following actions:

* Ensures the osg class is included (repo)
* Ensures the osg::cacerts class is included
* Installs osg-wn-client package
* Installs xrootd-client

Example:

```puppet
    class { 'osg::wn': }
```

### Types

#### osg\_local\_site_settings

The `osg_local_site_settings` custom type will configure values in `/etc/osg/config.d/99-local-site-settings.ini`.  Some of the values are set in this module's classes.  One example of a value not currently managed (though may be in the future):

```puppet
    osg_local_site_settings { 'Storage/se_available':
      value   => true,
    }
```

Note that boolean values of `true` and `false` are converted to the Python bool values of `True` and `False`.

#### osg\_gip_config

The `osg_gip_config` custom type will configure values in `/etc/osg/config.d/30-gip.ini`.  Example of setting your batch system to SLURM.

```puppet
    osg_gip_config { 'GIP/batch':
      value => 'slurm',
    }
```

You can also remove the settings defined in `30-gip.ini` and use the `osg_local_site_settings` type to define all configs in `/etc/osg/config.d/99-local-site-settings.ini`

```puppet
    resources { 'osg_gip_config': purge => true }
    osg_local_site_settings { 'GIP/batch':
      value => 'slurm',
    }
```

This can be useful as the `99-local-site-settings.ini` does not take precedence in GIP like it does with osg-configure  ([ref](https://opensciencegrid.org/docs/other/configuration-with-osg-configure/)).

## Reference

[http://treydock.github.io/puppet-osg/](http://treydock.github.io/puppet-osg/)

## Limitations

Tested operating systems:

* RedHat/CentOS 7

This module has only been thoroughly tested using OSG 3.5.

## Development

### Testing

Testing requires the following dependencies:

* rake
* bundler

Install gem dependencies

    bundle install

Run unit tests

    bundle exec rake spec

If you have Docker installed you can run system tests.

    bundle exec rake beaker
