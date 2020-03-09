Puppet::Type.type(:osg_local_site_settings).provide(
  :ini_setting,
  parent: Puppet::Type.type(:ini_setting).provider(:ruby),
) do
  desc 'Provider for osg_local_site_settings using ini_setting'

  def section
    resource[:name].split('/', 2).first
  end

  def setting
    resource[:name].split('/', 2).last
  end

  def separator
    ' = '
  end

  def self.file_path
    '/etc/osg/config.d/99-local-site-settings.ini'
  end
end
