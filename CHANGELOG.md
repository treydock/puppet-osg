# Change log

All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [v6.1.0](https://github.com/treydock/puppet-osg/tree/v6.1.0) (2022-06-27)

[Full Changelog](https://github.com/treydock/puppet-osg/compare/v6.0.0...v6.1.0)

### Added

- Enable upcoming repository by default [\#39](https://github.com/treydock/puppet-osg/pull/39) ([treydock](https://github.com/treydock))

## [v6.0.0](https://github.com/treydock/puppet-osg/tree/v6.0.0) (2022-04-18)

[Full Changelog](https://github.com/treydock/puppet-osg/compare/v5.2.1...v6.0.0)

### Changed

- Drop Puppet 5, Add Puppet 7 , bump module dependencies [\#38](https://github.com/treydock/puppet-osg/pull/38) ([treydock](https://github.com/treydock))

## [v5.2.1](https://github.com/treydock/puppet-osg/tree/v5.2.1) (2021-01-15)

[Full Changelog](https://github.com/treydock/puppet-osg/compare/v5.2.0...v5.2.1)

### Fixed

- Do not set SuppressNODNRecords, not needed [\#36](https://github.com/treydock/puppet-osg/pull/36) ([treydock](https://github.com/treydock))

## [v5.2.0](https://github.com/treydock/puppet-osg/tree/v5.2.0) (2021-01-07)

[Full Changelog](https://github.com/treydock/puppet-osg/compare/v5.1.0...v5.2.0)

### Added

- Use HTCondor-CE gratia probe by default [\#35](https://github.com/treydock/puppet-osg/pull/35) ([treydock](https://github.com/treydock))

## [v5.1.0](https://github.com/treydock/puppet-osg/tree/v5.1.0) (2020-12-16)

[Full Changelog](https://github.com/treydock/puppet-osg/compare/v5.0.0...v5.1.0)

### Added

- Remove unused OSG configurations and allow gratia-probes-cron to be turned off [\#34](https://github.com/treydock/puppet-osg/pull/34) ([treydock](https://github.com/treydock))

## [v5.0.0](https://github.com/treydock/puppet-osg/tree/v5.0.0) (2020-03-09)

[Full Changelog](https://github.com/treydock/puppet-osg/compare/v4.4.0...v5.0.0)

### Changed

- BREAKING: Misc changes [\#31](https://github.com/treydock/puppet-osg/pull/31) ([treydock](https://github.com/treydock))
- BREAKING: Switch to OSG 3.5 [\#30](https://github.com/treydock/puppet-osg/pull/30) ([treydock](https://github.com/treydock))

## [v4.4.0](https://github.com/treydock/puppet-osg/tree/v4.4.0) (2020-03-05)

[Full Changelog](https://github.com/treydock/puppet-osg/compare/4.3.1...v4.4.0)

### Added

- PDK convert and update dependencies [\#29](https://github.com/treydock/puppet-osg/pull/29) ([treydock](https://github.com/treydock))
- Allow repos to be disabled [\#28](https://github.com/treydock/puppet-osg/pull/28) ([wmoore28](https://github.com/wmoore28))

## [4.3.1](https://github.com/treydock/puppet-osg/tree/4.3.1) (2019-11-12)

[Full Changelog](https://github.com/treydock/puppet-osg/compare/4.3.0...4.3.1)

### Fixed

- Re-release 4.3.0 [\#27](https://github.com/treydock/puppet-osg/pull/27) ([treydock](https://github.com/treydock))
- Add work around for OSG-SEC-2019-11-11 [\#26](https://github.com/treydock/puppet-osg/pull/26) ([treydock](https://github.com/treydock))

## [4.3.0](https://github.com/treydock/puppet-osg/tree/4.3.0) (2019-11-11)

[Full Changelog](https://github.com/treydock/puppet-osg/compare/4.2.2...4.3.0)

### Added

- Support Puppet 5 & 6 and bump module dependencies [\#25](https://github.com/treydock/puppet-osg/pull/25) ([treydock](https://github.com/treydock))

### Fixed

- Remove old autofs parameter mapfile\_manage [\#24](https://github.com/treydock/puppet-osg/pull/24) ([wmoore28](https://github.com/wmoore28))

## [4.2.2](https://github.com/treydock/puppet-osg/tree/4.2.2) (2018-07-05)

[Full Changelog](https://github.com/treydock/puppet-osg/compare/4.2.1...4.2.2)

### Fixed

- Update rsv apache template to match upstream [\#23](https://github.com/treydock/puppet-osg/pull/23) ([treydock](https://github.com/treydock))

## [4.2.1](https://github.com/treydock/puppet-osg/tree/4.2.1) (2018-05-02)

[Full Changelog](https://github.com/treydock/puppet-osg/compare/4.2.0...4.2.1)

### Fixed

- Fix permissions for /bin/fusermount on EL6 [\#22](https://github.com/treydock/puppet-osg/pull/22) ([treydock](https://github.com/treydock))

## [4.2.0](https://github.com/treydock/puppet-osg/tree/4.2.0) (2018-04-24)

[Full Changelog](https://github.com/treydock/puppet-osg/compare/4.1.1...4.2.0)

### Added

- Make repo URLs match what is defined in latest osg-release RPMs [\#20](https://github.com/treydock/puppet-osg/pull/20) ([treydock](https://github.com/treydock))

### Fixed

- Limit osg-empty repo to packages installed [\#21](https://github.com/treydock/puppet-osg/pull/21) ([treydock](https://github.com/treydock))

## [4.1.1](https://github.com/treydock/puppet-osg/tree/4.1.1) (2018-01-09)

[Full Changelog](https://github.com/treydock/puppet-osg/compare/4.1.0...4.1.1)

### Fixed

- Allow autofs 4.x, apache 2.x and concat 4.x dependencies [\#19](https://github.com/treydock/puppet-osg/pull/19) ([treydock](https://github.com/treydock))

## [4.1.0](https://github.com/treydock/puppet-osg/tree/4.1.0) (2017-11-09)

[Full Changelog](https://github.com/treydock/puppet-osg/compare/4.0.0...4.1.0)

### Added

- Set RSV cert and key path for osg-configure and ensure the files exist before the values are set [\#17](https://github.com/treydock/puppet-osg/pull/17) ([treydock](https://github.com/treydock))
- Fully drop support for Puppet 3 [\#16](https://github.com/treydock/puppet-osg/pull/16) ([treydock](https://github.com/treydock))

### Fixed

- Fix rsv service resource to check status instead of presence of file [\#18](https://github.com/treydock/puppet-osg/pull/18) ([treydock](https://github.com/treydock))
- Remove unused variables [\#14](https://github.com/treydock/puppet-osg/pull/14) ([treydock](https://github.com/treydock))
- Remove sudo and logrotate dependencies, these modules are not used by this module [\#13](https://github.com/treydock/puppet-osg/pull/13) ([treydock](https://github.com/treydock))

## [4.0.0](https://github.com/treydock/puppet-osg/tree/4.0.0) (2017-10-02)

[Full Changelog](https://github.com/treydock/puppet-osg/compare/3.0.0...4.0.0)

### Changed

- Remove support for OSG 3.3 components [\#12](https://github.com/treydock/puppet-osg/pull/12) ([treydock](https://github.com/treydock))

### Added

- Move storage INI configurations to osg::ce [\#11](https://github.com/treydock/puppet-osg/pull/11) ([treydock](https://github.com/treydock))

## [3.0.0](https://github.com/treydock/puppet-osg/tree/3.0.0) (2017-10-02)

[Full Changelog](https://github.com/treydock/puppet-osg/compare/2.0.0...3.0.0)

### Changed

- Remove GRAM resources and only support HTCondor-CE gateway [\#10](https://github.com/treydock/puppet-osg/pull/10) ([treydock](https://github.com/treydock))
- Remove deprecated osg::lcmaps class [\#5](https://github.com/treydock/puppet-osg/pull/5) ([treydock](https://github.com/treydock))

### Added

- Switch all parameters to use proper data types [\#9](https://github.com/treydock/puppet-osg/pull/9) ([treydock](https://github.com/treydock))
- Set defaults for osg::osg\_release to 3.4 and osg::auth\_type to lcmaps\_voms [\#3](https://github.com/treydock/puppet-osg/pull/3) ([treydock](https://github.com/treydock))

### Fixed

- Only manage osg::ce http cert/key on OSG 3.3 [\#8](https://github.com/treydock/puppet-osg/pull/8) ([treydock](https://github.com/treydock))
- Do not manage tomcat user/group for OSG 3.4 for osg::ce [\#7](https://github.com/treydock/puppet-osg/pull/7) ([treydock](https://github.com/treydock))
- Puppet syntax cleanup [\#6](https://github.com/treydock/puppet-osg/pull/6) ([treydock](https://github.com/treydock))
- Add notify to resources that purge configs [\#4](https://github.com/treydock/puppet-osg/pull/4) ([treydock](https://github.com/treydock))
- Do not install empty-torque, no longer needed. [\#2](https://github.com/treydock/puppet-osg/pull/2) ([treydock](https://github.com/treydock))

## [2.0.0](https://github.com/treydock/puppet-osg/tree/2.0.0) (2017-09-26)

[Full Changelog](https://github.com/treydock/puppet-osg/compare/1.0.0...2.0.0)

## [1.0.0](https://github.com/treydock/puppet-osg/tree/1.0.0) (2017-05-04)

[Full Changelog](https://github.com/treydock/puppet-osg/compare/v0.0.3...1.0.0)

## [v0.0.3](https://github.com/treydock/puppet-osg/tree/v0.0.3) (2013-06-14)

[Full Changelog](https://github.com/treydock/puppet-osg/compare/v0.0.2...v0.0.3)

## [v0.0.2](https://github.com/treydock/puppet-osg/tree/v0.0.2) (2013-06-11)

[Full Changelog](https://github.com/treydock/puppet-osg/compare/ee1e0b91073be57d73d83e6069b4adbb6febe368...v0.0.2)



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
