require 'rubygems' 
require 'active_model'
require 'active_support'
require 'active_support/inflector'

require 'typhoeus'
require 'msgpack'
require 'hashie'
require 'facets'
require 'bunny'
require 'fcg-service-ext'
require 'fcg-core-ext'
include Hashie::HashExtensions

$LOAD_PATH.unshift(File.dirname(__FILE__))

# load all client files
Dir[
  File.expand_path("../service/client/base.rb", __FILE__),
  File.expand_path("../service/client/configuration.rb", __FILE__),
  File.expand_path("../service/client/sender.rb", __FILE__),
  File.expand_path("../fcg_service_clients/thor/*.rb", __FILE__),
  File.expand_path("../fcg_service_clients/*.rb", __FILE__),
  File.expand_path("../fcg_service_clients/client/*.rb", __FILE__)
].each do |file|
  require file
end

module FCG
  module Client
    # autoload all models
    Dir[
      File.expand_path("../fcg_service_clients/models/*.rb", __FILE__)
    ].each do |file|
      name = File.basename(file, ".rb")
      autoload "#{name.classify}".to_sym, file
    end
  end
end