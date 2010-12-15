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

__END__
class User
  include FCG::Client::User
  setup_service :hydra => FCG::Client::Base::HYDRA, :host => "http://0.0.0.0:5678", :version => "v1"
end
 
1.upto(3).each do |i|
  puts "Pass ##{i}"
  t = User.find("4cbeaf2842572108ed000001")
  puts t.id
end