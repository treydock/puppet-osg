# osg_version.rb

begin
  require 'facter/util/file_read'
rescue LoadError => e
  require 'facter/util/file_read_ext'
end

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
