require 'tmpdir'

module Heirloom
  module Misc
    module Tmp
      def tmp_archive
        random_text = (0...8).map{65.+(Kernel.rand(25)).chr}.join
        local_build = File.join(Dir.tmpdir, random_text + ".tar.gz")
      end
    end
  end
end
