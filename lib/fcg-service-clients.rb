require "rubygems"
require 'fcg-service-ext'

$LOAD_PATH.unshift(File.dirname(__FILE__))

# load all models + version.rb
Dir[
  File.expand_path("../fcg_service_clients/*.rb", __FILE__)
].each do |file|
  require file
end