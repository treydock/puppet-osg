Puppet::Type.type(:osg_config).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:ini_setting).provider(:ruby)
) do

  def self.instances
    if self.respond_to?(:file_path)
      resources = []
      ini_file = Puppet::Util::IniFile.new(file_path, ' = ')
      ini_file.section_names.each do |section_name|
        ini_file.get_settings(section_name).each do |setting, value|
          resources.push(
            new(
              :name   => namevar(section_name, setting),
              :value  => value,
              :ensure => :present
            )
          )
        end
      end
      resources
    else
      raise(Puppet::Error, 'Ini_settings only support collecting instances when a file path is hard coded')
    end
  end

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
    nil
  end
end
