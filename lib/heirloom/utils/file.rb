module Heirloom
  module Utils
    module File

      def which(cmd)
        exts = pathext ? pathext.split(';') : ['']
        path.split(path_separator).each do |path|
          exts.each { |ext|
            exe = "#{path}/#{cmd}#{ext}"
            return exe if ::File.executable? exe
          }
        end
        return nil
      end

      def path_separator
        ::File::PATH_SEPARATOR
      end

      def path
        ENV['PATH']
      end

      def pathext
        ENV['PATHEXT']
      end

    end
  end
end
