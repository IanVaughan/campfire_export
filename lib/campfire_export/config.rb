require 'yaml'

module CampfireExport
  class Config
    # attr_accessor :subdomain, :api_token, :start_date, :end_date

    CONFIG_FILE = File.join(ENV['HOME'], 'campfire_export.yml')

    def initialize(file = CONFIG_FILE)
      @config = YAML.load_file(file) if File.exists?(file) && File.readable?(file)
      #@config.symbolize_keys unless @config.nil?

      @subdomain = ensure_config_for(:subdomain, "Your Campfire subdomain (for 'https://myco.campfirenow.com', use 'myco')")
      @api_token = ensure_config_for(:api_token, "Your Campfire API token (see 'My Info' on your Campfire site)")
      @start_date = convert_date(:start_date)
      @end_date = convert_date(:end_date)
    end

    def included_rooms?
      @config.has_key?('included_rooms')
    end

    def included_rooms
      @config['included_rooms']
    end

    def excluded_rooms?
      @config.has_key?('excluded_rooms')
    end

    def excluded_rooms
      @config['excluded_rooms']
    end

    private

    def ensure_config_for(key, prompt)
      value = @config.fetch(key, nil) || @config.fetch(key.to_s, nil)
      while value == ""
        print "#{prompt}: "
        value = gets.chomp
      end
      value
    end

    def convert_date(date_key)
      date_str = @config.fetch(date_key, nil) || @config.fetch(date_key.to_s, nil)
      date_str.nil? ? nil : Date.parse(date_str)
    end
  end
end