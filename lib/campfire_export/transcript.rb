module CampfireExport
  class Transcript
    include IO
    attr_accessor :room, :date, :xml, :messages

    def initialize(room, date)
      @room = room
      @date = date
    end

    def transcript_path
      "/room/#{room.id}/transcript/#{date.year}/#{date.mon}/#{date.mday}"
    end

    def export(dir)
      log(:info, "#{dir} ... ")
      begin
        @xml = Nokogiri::XML get("#{transcript_path}.xml").body
      rescue Exception => e
        log(:error, "transcript export for #{dir} failed", e)
      else
        @messages = xml.xpath('/messages/message').map do |message|
          CampfireExport::Message.new(message, room, date)
        end

        # Only export transcripts that contain at least one message.
        if messages.length > 0
          log(:info, "exporting transcripts\n")
          begin
            FileUtils.mkdir_p dir
          rescue Exception => e
            log(:error, "Unable to create #{dir}", e)
          else
            export_xml(dir)
            export_plaintext(dir)
            export_html(dir)
            export_uploads(dir)
          end
        else
          log(:info, "no messages\n")
        end
      end
    end

    def export_xml(dir)
      begin
        export_file(dir, xml, 'transcript.xml')
        verify_export(dir, 'transcript.xml', xml.to_s.length)
      rescue Exception => e
        log(:error, "XML transcript export for #{dir} failed", e)
      end
    end

    def export_plaintext(dir)
      begin
        date_header = date.strftime('%A, %B %e, %Y').squeeze(" ")
        plaintext = "#{CampfireExport::Account.subdomain.upcase} CAMPFIRE\n"
        plaintext << "#{room.name}: #{date_header}\n\n"
        messages.each {|message| plaintext << message.to_s }
        export_file(dir, plaintext, 'transcript.txt')
        verify_export(dir, 'transcript.txt', plaintext.length)
      rescue Exception => e
        log(:error, "Plaintext transcript export for #{dir} failed", e)
      end
    end

    def export_html(dir)
      begin
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
    end

    def export_uploads(dir)
      messages.each do |message|
        if message.is_upload?
          begin
            message.upload.export(dir)
          rescue Exception => e
            path = "#{dir}/#{message.upload.filename}"
            log(:error, "Upload export for #{path} failed", e)
          end
        end
      end
    end
  end
end