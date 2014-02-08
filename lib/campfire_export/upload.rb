module CampfireExport
  class Upload
    include IO

    def initialize(message)
      @message = message
      @room = message.room
      @date = message.date
      @deleted = false
    end

    private
    attr_accessor :message, :room, :date, :id, :filename, :content_type, :byte_size, :full_url

    def deleted?
      @deleted
    end

    def is_image?
      content_type.start_with?("image/")
    end

    def upload_dir
      File.join("uploads", id.to_s)
    end

    # Image thumbnails are used to inline image uploads in HTML transcripts.
    def thumb_dir
      File.join("thumbs", id.to_s)
    end


    def upload_path
      "/room/#{room.id}/messages/#{message.id}/upload"
    end

    def export(dir)
      log(:info, "    #{message.body} ... ")
      begin
        # Get the upload object corresponding to this message.
        upload = IO.get(upload_path, )
      rescue Exception => e
        if e.code == 404
          # If the upload 404s, that should mean it was subsequently deleted.
          @deleted = true
          return log(:info, "deleted\n")
        else
          raise e
        end
      end

      # Get the upload itself and export it.
      @id = upload.xpath('/upload/id').text
      @byte_size = upload.xpath('/upload/byte-size').text.to_i
      @content_type = upload.xpath('/upload/content-type').text
      @filename = upload.xpath('/upload/name').text
      @full_url = upload.xpath('/upload/full-url').text

      export_content(dir, upload_dir)
      export_content(dir, thumb_dir, path_component="thumb/#{id}", verify=false) if is_image?

      log(:info, "ok\n")
    end

    def export_content(dir, content_dir, path_component=nil, verify=true)
      # If the export directory name is different than the URL path component,
      # the caller can define the path_component separately.
      path_component ||= content_dir

      # Write uploads to a subdirectory, using the upload ID as a directory
      # name to avoid overwriting multiple uploads of the same file within
      # the same day (for instance, if 'Picture 1.png' is uploaded twice
      # in a day, this will preserve both copies). This path pattern also
      # matches the tail of the upload path in the HTML transcript, making
      # it easier to make downloads functional from the HTML transcripts.
      content_path = "/room/#{room.id}/#{path_component}/#{CGI.escape(filename)}"
      content = get(content_path).body
      FileUtils.mkdir_p(File.join(dir, content_dir))
      export_file(dir, content, File.join(content_dir, filename), 'wb')
      verify_export(dir, File.join(content_dir, filename), byte_size.to_s) if verify
    end
  end
end