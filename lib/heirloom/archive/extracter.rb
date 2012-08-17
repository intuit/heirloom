module Heirloom
  class Extracter

    include Heirloom::Misc::Tmp

    def intialize(args)
      @config = args[:config]
      @logger = @config.logger
      @tmp_archive = random_archive
    end

    def extract(args)
      archive = args[:archive]
      output = args[:output]

      create_tmp_archive archive
      extract_tmp_archive output
      delete_tmp_archive
    end

    private

    def extract_tmp_archive(output)
      @logger.info "Extracting archive to #{output}."
      cmd = "tar xzf #{@tmp_archive} -C #{output}"
      @logger.debug "Executing '#{cmd}'."
      `#{cmd}`
    end

    def create_tmp_archive(archive)
      File.open(@tmp_archive, 'w') { |local_file| local_file.write archive }
    end
  
    def delete_tmp_archive
      File.delete @tmp_archive
    end

  end
end
