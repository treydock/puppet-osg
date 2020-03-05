# @summary Manage OSG configuration site info
# @api private
class osg::configure::site_info {
  osg_local_site_settings { 'Site Information/group': value => $osg::site_info_group }
  osg_local_site_settings { 'Site Information/host_name': value => $osg::site_info_host_name }
  osg_local_site_settings { 'Site Information/resource': value => $osg::site_info_resource }
  osg_local_site_settings { 'Site Information/resource_group': value => $osg::site_info_resource_group }
  osg_local_site_settings { 'Site Information/sponsor': value => $osg::site_info_sponsor }
  osg_local_site_settings { 'Site Information/site_policy': value => $osg::site_info_site_policy }
  osg_local_site_settings { 'Site Information/contact': value => $osg::site_info_contact }
  osg_local_site_settings { 'Site Information/email': value => $osg::site_info_email }
  osg_local_site_settings { 'Site Information/city': value => $osg::site_info_city }
  osg_local_site_settings { 'Site Information/country': value => $osg::site_info_country }
  osg_local_site_settings { 'Site Information/longitude': value => $osg::site_info_longitude }
  osg_local_site_settings { 'Site Information/latitude': value => $osg::site_info_latitude }
}