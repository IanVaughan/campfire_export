lib = File.expand_path(File.join(File.dirname(__FILE__), '../lib'))
$LOAD_PATH.unshift(lib) if File.directory?(lib) && !$LOAD_PATH.include?(lib)

require 'nokogiri'

require 'cgi'
require 'fileutils'
require 'httparty'
require 'time'

require './lib/campfire_export/io.rb'

Dir[File.dirname(__FILE__) + '/campfire_export/*.rb'].each {|file| require file }

# module CampfireExport
# end
