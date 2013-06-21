# osg_version.rb

begin
  require 'facter/util/file_read'
rescue LoadError => e
  # puppet apply does not add module lib directories to the $LOAD_PATH (See
  # #4248). It should (in the future) but for the time being we need to be
  # defensive which is what this rescue block is doing.
  rb_file = File.join(File.dirname(__FILE__), 'util', 'file_read.rb')
  load rb_file if File.exists?(rb_file) or raise e
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
