module FCG
  module Client
    module Stat
      module ClassMethods
        def views(key, time)
          # "/:verb/:key/:time"
          verb = "view"
          request = Typhoeus::Request.new(
            "#{self.service_url}/#{verb}/#{key}/#{time}",
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
        receiver.extend         ClassMethods
        receiver.send :include, FCG::Client::Fetcher
      end
    end
  end
end