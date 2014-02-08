module CampfireExport
  class Message
    attr_accessor :id, :room, :body, :type, :user, :date, :timestamp, :upload

    def initialize(message, room, date)
      @id = message.xpath('id').text
      @room = room
      @date = date
      @body = message.xpath('body').text
      @type = message.xpath('type').text

      time = Time.parse message.xpath('created-at').text
      localtime = Account.timezone.utc_to_local(time)
      @timestamp = localtime.strftime '%I:%M %p'

      no_user = ['TimestampMessage', 'SystemMessage', 'AdvertisementMessage']
      unless no_user.include?(@type)
        @user = username(message.xpath('user-id').text)
      end

      @upload = Upload.new(self) if is_upload?
      @usernames = {}
    end

    private

    def username(user_id)
      @usernames[user_id] ||= get_user(user_id)
    end

    def get_user(user_id)
      begin
        doc = IO.get("/users/#{user_id}", '/user/name').body
      rescue Exception => e
        return "[unknown user]"
      end

      get_first_name_with_last_initial(doc.text)
    end

    def get_first_name_with_last_initial(doc_text)
      # Take the first name and last initial, if there is more than one name.
      name_parts = doc_text.split
      if name_parts.length > 1
        name_parts[-1] = "#{name_parts.last[0,1]}."
        name_parts.join(" ")
      else
        name_parts[0]
      end
    end

    def is_upload?
      @type == 'UploadMessage'
    end

    def indent(string, count)
      (' ' * count) + string.gsub(/(\n+)/) { $1 + (' ' * count) }
    end

    def to_s
      case type
      when 'EnterMessage'
        "[#{user} has entered the room]\n"
      when 'KickMessage', 'LeaveMessage'
        "[#{user} has left the room]\n"
      when 'TextMessage'
        "[#{user.rjust(12)}:] #{body}\n"
      when 'UploadMessage'
        "[#{user} uploaded: #{body}]\n"
      when 'PasteMessage'
        "[" + "#{user} pasted:]".rjust(14) + "\n#{indent(body, 16)}\n"
      when 'TopicChangeMessage'
        "[#{user} changed the topic to: #{body}]\n"
      when 'ConferenceCreatedMessage'
        "[#{user} created conference: #{body}]\n"
      when 'AllowGuestsMessage'
        "[#{user} opened the room to guests]\n"
      when 'DisallowGuestsMessage'
        "[#{user} closed the room to guests]\n"
      when 'LockMessage'
        "[#{user} locked the room]\n"
      when 'UnlockMessage'
        "[#{user} unlocked the room]\n"
      when 'IdleMessage'
        "[#{user} became idle]\n"
      when 'UnidleMessage'
        "[#{user} became active]\n"
      when 'TweetMessage'
        "[#{user} tweeted:] #{body}\n"
      when 'SoundMessage'
        "[#{user} played a sound:] #{body}\n"
      when 'TimestampMessage'
        "--- #{timestamp} ---\n"
      when 'SystemMessage'
        ""
      when 'AdvertisementMessage'
        ""
      else
        log(:error, "unknown message type: #{type} - '#{body}'")
        ""
      end
    end
  end
end