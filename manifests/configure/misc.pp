# @summary Manage osg-configure-misc
# @api private
class osg::configure::misc {
  package { 'osg-configure-misc':
    ensure => 'present',
  }
}