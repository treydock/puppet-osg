# @summary Install GridFTP
# @api private
class osg::gridftp::install {

  package { 'osg-gridftp':
    ensure  => 'present',
  }

}
