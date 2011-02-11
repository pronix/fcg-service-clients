require 'rubygems' 
require 'active_model'
require 'active_support'
require 'typhoeus'
require 'msgpack'
require 'hashie'
require 'facets'
require 'bunny'
require 'fcg-service-ext'
require 'fcg-core-ext'
include Hashie::HashExtensions

# ActiveModel::Base.include_root_in_json

$LOAD_PATH.unshift(File.dirname(__FILE__))

# load all models + client files
Dir[
  File.expand_path("../fcg_service_clients/thor/*.rb", __FILE__),
  File.expand_path("../fcg_service_clients/*.rb", __FILE__),
  File.expand_path("../fcg_service_clients/client/*.rb", __FILE__),
  File.expand_path("../fcg_service_clients/models/*.rb", __FILE__)
].each do |file|
  require file
end