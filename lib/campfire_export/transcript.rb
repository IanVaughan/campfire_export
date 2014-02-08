module CampfireExport
  class Transcript
    include IO

    def initialize(room, date)
      @room = room
      @date = date
    end

    def export(dir)
      log(:info, "#{dir}...")
      begin
        @xml = IO.get("#{transcript_path}", '/messages/message')
      rescue Exception => e
        return log(:error, "transcript export for #{dir} failed", e)
      end

      @messages = xml.map do |message|
        Message.new(message, room, date)
      end
      return log(:info, "no messages\n") if messages.size == 0

      log(:info, "exporting transcripts\n")

      begin
        FileUtils.mkdir_p dir
      rescue Exception => e
        return log(:error, "Unable to create #{dir}", e)
      end

      export_xml(xml, dir)
      export_plaintext(dir)
      export_html(dir)
      export_uploads(dir)
    end

    private
    attr_accessor :room, :date, :messages, :xml

    def export_xml(xml, dir)
      export_file(dir, xml, 'transcript.xml') # , :verify: true)
      verify_export(dir, 'transcript.xml', xml.to_s.length)
    rescue Exception => e
      log(:error, "XML transcript export for #{dir} failed", e)
    end

    def date_header
      date.strftime('%A, %B %e, %Y').squeeze(" ")
    end

    def export_plaintext(dir)
      plaintext = "#{Account.subdomain.upcase} CAMPFIRE\n"
      plaintext << "#{room.name}: #{date_header}\n\n"
      messages.each {|message| plaintext << message.to_s }
      export_file(dir, plaintext, 'transcript.txt')
      verify_export(dir, 'transcript.txt', plaintext.length)
    rescue Exception => e
      log(:error, "Plaintext transcript export for #{dir} failed", e)
    end

    def export_html(dir)
      transcript_html = get(transcript_path)

      # Make the upload links in the transcript clickable from the exported
      # directory layout.
      transcript_html.gsub!(%Q{href="/room/#{room.id}/uploads/},
                            %Q{href="uploads/})

      # Likewise, make the image thumbnails embeddable from the exported
      # directory layout.
      transcript_html.gsub!(%Q{src="/room/#{room.id}/thumb/},
                            %Q{src="thumbs/})

      export_file(dir, transcript_html, 'transcript.html')
      verify_export(dir, 'transcript.html', transcript_html.length)
    rescue Exception => e
      log(:error, "HTML transcript export for #{dir} failed", e)
    end

    def export_uploads(dir)
      messages.each do |message|
        if message.is_upload?
          begin
            message.upload.export(dir)
          rescue Exception => e
            path = File.join(dir, message.upload.filename)
            log(:error, "Upload export for #{path} failed", e)
          end
        end
      end
    end

    def transcript_path
      "/room/#{room.id}/transcript/#{date.year}/#{date.mon}/#{date.mday}"
    end
  end
end