module Facter
  module Util
    module FileRead
      def self.read(path)
        File.read(path)
      rescue Errno::ENOENT, Errno::EACCES => detail
        Facter.debug "Could not read #{path}: #{detail.message}"
        nil
      end
    end
  end
end