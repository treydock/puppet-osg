# puppet-osg

[![Build Status](https://travis-ci.org/treydock/puppet-osg.png)](https://travis-ci.org/treydock/puppet-osg)

This module will be changing drastically as it's developed and is a work in progress to Puppet-ize the installation and management of the OSG software stack.

## Support

Tested using
* Scientific 6.4

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

Requires the *osg::lcmaps* class.

Example of configuring a Bestman2 server.

    class { 'osg::lcmaps':
      gums_hostname => 'gums.yourdomain.tld',
    }
    class { 'osg::bestman':
      with_gums_auth        => true,
      localPathListAllowed  => ['/tmp','/home','/data'],
      supportedProtocolList => ['gsiftp://gridftp.yourdomain.tld'],
      noSudoOnLs            => false,
    }

## Development

### Dependencies

* Ruby 1.8.7
* Bundler
* Vagrant >= 1.2.0

### Unit testing

1. To install dependencies run `bundle install`
2. Run tests using `bundle exec rake spec:all`

### Vagrant system tests

1. Have Vagrant >= 1.2.0 installed
2. Run tests using `bundle exec rake spec:system`

For active development the `RSPEC_DESTROY=no` environment variable can be passed to keep the Vagrant VM from being destroyed after a test run.

    RSPEC_DESTROY=no bundle exec rake spec:system

To test on CentOS 6.4 run the following:

    RSPEC_DESTROY=centos-64-x64 bundle exec rake spec:system

## TODO

* Expand CA Certs to handle all the possible options documented by OSG.  [Ref](https://twiki.grid.iu.edu/bin/view/Documentation/Release3/InstallCertAuth)

## Further Information

* [Bestman2](https://twiki.grid.iu.edu/bin/view/Documentation/Release3/InstallOSGBestmanSE)
