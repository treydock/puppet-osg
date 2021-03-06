Puppet::Type.newtype(:osg_local_site_settings) do
  desc <<-DESC
  This type writes values to `/etc/osg/config.d/99-local-site-settings.ini`.
  DESC
  ensurable

  newparam(:name, namevar: true) do
    desc <<-DESC
    The name must be in the format of `SECTION/SETTING`

        [Squid]
        location = squid.example.tld

    The above would have the name `Squid/location`.
    DESC
    # namevar should be of the form section/setting
    validate do |value|
      unless value =~ %r{\S+/\S+}
        raise("Invalid osg_local_site_settings #{value}, entries should be in the form of section/setting.")
      end
    end
  end

  newproperty(:value) do
    desc <<-DESC
    The value to assign.
    A value of `true` is converted to the string `True`.
    A value of `false` is converted to the string `False`.
    All other values are converted to a string.
    DESC
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
