module CampfireExport
  class Account
    # attr_accessor :subdomain, :api_token, :base_url, :timezone

    def initialize(subdomain, api_token)
      @subdomain = subdomain
      @api_token = api_token
      @base_url  = "https://#{@subdomain}.campfirenow.com"
      @timezone  = nil

      find_timezone
    end

    def find_timezone
      selected_zone = IO.get('/account', '/account/time-zone')
      @timezone = TimeZone.find_tzinfo(selected_zone.text)
    end

    def rooms
      IO.get('/rooms', '/rooms/room').map {|room_xml| Room.new(room_xml) }
      # @rooms ||= x
    end

    def all_room_names
      rooms.map { |r| "'#{r.name}'" }.join(", ")
    end
  end
end