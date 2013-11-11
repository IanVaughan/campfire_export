module CampfireExport
  module IO
    def api_url(path)
      "#{CampfireExport::Account.base_url}#{path}"
    end

    def get(path, params = {})
      url = api_url(path)

      response = HTTParty.get(url,
        :query => params,
        :basic_auth => {:username => CampfireExport::Account.api_token, :password => 'X'})

      if response.code >= 400
        raise Exception.new(url, response.message, response.code)
      end
      response
    end

    def zero_pad(number)
      "%02d" % number
    end

    # Requires that room and date be defined in the calling object.
    def export_dir
      "campfire/#{Account.subdomain}/#{room.name}/" +
        "#{date.year}/#{zero_pad(date.mon)}/#{zero_pad(date.day)}"
    end

    # Requires that room_name and date be defined in the calling object.
    def export_file(content, filename, mode='w')
      # Check to make sure we're writing into the target directory tree.
      true_path = File.expand_path(File.join(export_dir, filename))

      unless true_path.start_with?(File.expand_path(export_dir))
        raise CampfireExport::Exception.new("#{export_dir}/#{filename}",
          "can't export file to a directory higher than target directory; " +
          "expected: #{File.expand_path(export_dir)}, actual: #{true_path}.")
      end

      if File.exists?("#{export_dir}/#{filename}")
        log(:error, "#{export_dir}/#{filename} failed: file already exists")
      else
        open("#{export_dir}/#{filename}", mode) do |file|
          file.write content
        end
      end
    end

    def verify_export(filename, expected_size)
      full_path = "#{export_dir}/#{filename}"
      unless File.exists?(full_path)
        raise CampfireExport::Exception.new(full_path,
          "file should have been exported but did not make it to disk")
      end
      unless File.size(full_path) == expected_size
        raise CampfireExport::Exception.new(full_path,
          "exported file exists but is not the right size " +
          "(expected: #{expected_size}, actual: #{File.size(full_path)})")
      end
    end

    def log(level, message, exception=nil)
      case level
      when :error
        short_error = ["*** Error: #{message}", exception].compact.join(": ")
        $stderr.puts short_error
        open("campfire/export_errors.txt", 'a') do |log|
          log.write short_error
          unless exception.nil?
            log.write %Q{\n\t#{exception.backtrace.join("\n\t")}}
          end
          log.write "\n"
        end
      else
        print message
        $stdout.flush
      end
    end
  end
end