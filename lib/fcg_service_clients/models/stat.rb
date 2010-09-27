module FCG
  module Client
    module Stat
      module ClassMethods
        def views(key, time)
          # "/:verb/:key/:time"
          verb = "view"
          request = Typhoeus::Request.new(
            "#{service_url}/#{verb}/#{key}/#{time}",
            :method => :get)
          
          request.on_complete do |response|
            handle_service_response(response)
          end

          hydra.queue(request)
          hydra.run

          request.handled_response
        end
      
        def top_views(rankable_key, model, time)
          # /rank/:verb/:rankable_key/:model/:time
          # /rank/view/citycode:nyc/image/20100926 returns top images limited to nyc from Sept 26, 2010
          verb = "view"
          request = Typhoeus::Request.new(
            "#{self.service_url}/rank/#{verb}/#{rankable_key}/#{model}/#{time}",
            :method => :get)

          request.on_complete do |response|
            handle_service_response(response)
          end

          self.hydra.queue(request)
          self.hydra.run

          request.handled_response
        end
      end
      
      def self.included(receiver)
        receiver.send :include, FCG::Client::Base
        receiver.extend         ClassMethods
      end
    end
  end
end