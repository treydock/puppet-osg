# puppet-osg

[![Build Status](https://travis-ci.org/treydock/puppet-osg.png)](https://travis-ci.org/treydock/puppet-osg)

## Overview

**This module is still under development.  Use at your own risk!**

This module is a work-in-progress intended to Puppet-ize the installation and management of the OSG software stack.

## Usage

### osg::lcmaps

The minimal parameters necessary to use the osg::lcmaps class.

    class { 'osg::lcmaps':
      gums_hostname => 'gums.yourdomain.tld',
    }

### osg::gums

Installs the OSG GUMS service and performs initial setup.

    class { 'osg::gums':
      db_password => 'secret',
    }

After Puppet applies this class, a script at `/root/gums-post-install.sh` can be run or used as reference to perform the remaining setup steps for GUMS.

### osg::bestman

Requires the *osg::lcmaps* class and the *sudo* class.

Example of configuring a Bestman2 server.

    class { 'sudo': }
    class { 'osg::lcmaps':
      gums_hostname => 'gums.yourdomain.tld',
    }
    class { 'osg::bestman':
      with_gums_auth        => true,
      localPathListAllowed  => ['/tmp','/home','/data'],
      supportedProtocolList => ['gsiftp://gridftp.yourdomain.tld'],
      noSudoOnLs            => false,
    }

### osg::rsv

Configure RSV monitoring.

Example of configuring RSV for a bestman2 SRM server

    class { 'osg::rsv':
      srm_hosts => 'srm.yourdomain.tld',
      srm_dir   => '/data/rsvhome',
    }

By default this class will put the necessary settings in **/etc/osg/config.d/30-rsv.ini**.  The actual configuration of RSV would require the manual execution of **osg-configure**.

## Compatibility

Tested using

* CentOS 6.4
* Scientific Linux 6.4

## Development

### Testing

Testing requires the following dependencies:

* rake
* bundler

Install gem dependencies

    bundle install

Run unit tests

    bundle exec rake ci

If you have Vagrant >= 1.2.0 installed you can run system tests

    bundle exec rake spec:system

## TODO

* Rename the osg::lcmaps class and resources to osg::gums::client to better reflect their purpose
* Move osg::gums to osg::gums::server onec osg::gums::client class is in place
* Utilize osg-configure
* Allow non-RPM condor-cron via 'empty-condor' package
* Manage resources for Compute Elements
* Manage GridFTP related resources

## Further Information

* [Bestman2](https://twiki.grid.iu.edu/bin/view/Documentation/Release3/InstallOSGBestmanSE)
* [RSV](https://twiki.grid.iu.edu/bin/view/Documentation/Release3/InstallRSV)
