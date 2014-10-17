Puppet::Type.newtype(:osg_local_site_settings) do

  @@file_path = "/etc/osg/config.d/99-local-site-settings.ini"

  ensurable

  newparam(:name, :namevar => true) do
    desc "Section/setting name to manage from #{@@file_path}"
    # namevar should be of the form section/setting
    validate do |value|
      unless value =~ /\S+\/\S+/
        fail("Invalid osg_local_site_settings #{value}, entries should be in the form of section/setting.")
      end
    end
  end

  newproperty(:value) do
    desc 'The value of the setting to be defined.'
    munge do |v|
      case v
      when TrueClass
        'True'
      when FalseClass
        'False'
      else
        v.to_s.strip
      end
    end
  end

  validate do
    if self[:ensure] == :present
      if self[:value].nil?
        raise Puppet::Error, "Property value must be set for #{self[:name]} when ensure is present"
      end
    end
  end
end
