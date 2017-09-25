# osg_version.rb

Facter.add(:osg_version) do
  confine :osfamily => "RedHat"
  setcode do
    osg_version_file = '/etc/osg-version'
    if File.exists?(osg_version_file)
      content = Facter::Core::Execution.execute("cat #{osg_version_file} 2>/dev/null")
      version = content.split("\n").first.chomp
      version
    end
  end
end
