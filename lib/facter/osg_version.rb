# osg_version.rb

require 'facter/util/file_read'

Facter.add(:osg_version) do
  confine :osfamily => "RedHat"
  setcode do
    osg_version_file = '/etc/osg-version'
    if content = Facter::Util::FileRead.read(osg_version_file)
      version = content.split("\n").first.chomp
      version
    end
  end
end
