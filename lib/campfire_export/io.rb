module CampfireExport
  module IO
    def api_url(path)
      "#{Account.base_url}#{path}"
    end

    def get(path, xpath, params = {})
      url = api_url(path + ".xml")

      response = HTTParty.get(url,
        :query => params,
        :basic_auth => {:username => Account.api_token, :password => 'X'})

      if response.code >= 400
        raise Exception.new(url, response.message, response.code)
      end

      xml_response = Nokogiri::XML response.body
      xml_response.xpath(xpath)
    end

    def zero_pad(number)
      "%02d" % number
    end

    def export_dir(room, date)
      File.join("campfire",
        Account.subdomain,
        room.name,
        date.year.to_s,
        zero_pad(date.mon),
        zero_pad(date.day))
    end

    # Requires that room_name and date be defined in the calling object.
    def export_file(dir, content, filename, mode='w')
      # Check to make sure we're writing into the target directory tree.
      true_path = File.expand_path(File.join(dir, filename))

      unless true_path.start_with?(File.expand_path(dir))
        raise Exception.new("#{dir}/#{filename}",
          "can't export file to a directory higher than target directory; " +
          "expected: #{File.expand_path(dir)}, actual: #{true_path}.")
      end

      if File.exists?("#{dir}/#{filename}")
        log(:info, "#{dir}/#{filename} : file already exists - skipping")
      else
        open("#{dir}/#{filename}", mode) do |file|
          file.write content
        end
      end
    end

    def verify_export(dir, filename, expected_size)
      full_path = File.join(dir, filename)

      msg = "file should have been exported but did not make it to disk"
      raise Exception.new(full_path, msg) unless File.exists?(full_path)

      if File.size(full_path) != expected_size - 2 || File.size(full_path) != expected_size
        msg = "exported file exists but is not the right size " +
          "(expected: #{expected_size}, actual: #{File.size(full_path)})"
        raise Exception.new(full_path, msg)
      end
    end

    def log(level, message, exception=nil)
      case level
      when :error
        short_error = ["*** Error: #{message}", exception].compact.join(": ")
        $stderr.puts short_error
        open("log/export_errors.log", 'a') do |log|
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