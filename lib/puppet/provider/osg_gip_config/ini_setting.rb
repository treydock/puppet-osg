Puppet::Type.type(:osg_gip_config).provide(
  :ini_setting,
  parent: Puppet::Type.type(:ini_setting).provider(:ruby),
) do
  desc 'Provider for osg_gip_config using ini_setting'

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
    '/etc/osg/config.d/30-gip.ini'
  end
end
