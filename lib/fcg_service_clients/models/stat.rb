module FCG
  module Client
    module Stat
      module ClassMethods
        def views(key)
          verb = "view"
          request = send_to_server(:method => :get, :path => "#{service_url}/#{verb}/#{key}", :params => params)
          handle_service_response request.handled_response
        end
      
        def top_views(rankable_key, model, time)
          # /rank/:verb/:rankable_key/:model/:time
          # /rank/view/region:nyc/image/20100926 returns top images limited to nyc from Sept 26, 2010
          verb = "view"
          request = send_to_server(:method => :get, :path => "#{self.service_url}/rank/#{verb}/#{rankable_key}/#{model}/#{time}", :params => params)
          handle_service_response request.handled_response
        end
        
        def most_visited(*args)
          opts = args.extract_options!
          params = {
            :limit => 10,
            :skip => 0
          }.merge(opts)
          
          request = send_to_server(:method => :get, :path => "#{self.service_url}/most_visited", :params => params)
          handle_service_response request.handled_response
        end

        def top_albums(*args)
          opts = args.extract_options!
          params = {
            :limit => 10,
            :skip => 0
          }.merge(opts)

          request = send_to_server(:method => :get, :path => "#{self.service_url}/top_albums", :params => params)
          handle_service_response request.handled_response
        end
      end
      
      def self.included(receiver)
        receiver.send :include, FCG::Client::Base
        receiver.extend         ClassMethods
      end
    end
  end
end