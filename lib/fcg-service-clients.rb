require 'rubygems'
require 'active_model'
require 'active_support'
require 'typhoeus'
require 'msgpack'
require 'hashie'
require 'facets'
require 'bunny'
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

class Stat
  include FCG::Client::Stat
  setup_service :model => "stats", :hydra => FCG::Client::Base::HYDRA, :host => "http://0.0.0.0:5678", :version => "v1"
end
 
1.upto(1).each do |i|
  puts "Pass ##{i}"
  # t = Stat.views("image:4c4e7da0ff808d20c9000003", 201009)
  # puts t.inspect
  
  s = Stat.top_views("citycode:nyc", "image", 20100926)
  puts s.inspect
end

# class Run
#   ATTRIBUTES = [:id, :bio, :created_at, :crypted_password, :date_of_birth, :deleted_at, :email, 
#     :facebook_id, :facebook_proxy_email, :facebook_session, :flags, :flyers, :last_visited_at, 
#     :location, :names, :password, :photo_album, :photo_count, :photos, :posted_party_at, :profile_image, 
#     :salt, :sex, :site_specific_settings, :token_expire_at, :token_id, :tokens_expire_at, 
#     :twitter_username, :updated_at, :uploaded_photos_at, :username, :web]
#   attr_accessor *ATTRIBUTES
#   include FCG::Client::Persistence
#   setup_service :model => "users", :hydra => FCG::Client::HYDRA, :host => "http://127.0.0.1:5678", :version => "v1"
#   before_save :pring
#   
#   def pring
#     "puts pring"
#   end
# end
# 
# 1.upto(3).each do |i|
#   puts "Pass ##{i}"
#   t = Run.find("4c401627ff808d982a00000b")
#   puts t.inspect
# end