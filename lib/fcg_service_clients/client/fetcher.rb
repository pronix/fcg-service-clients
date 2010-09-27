module FCG
  module Client
    module Fetcher
      module ClassMethods
        def handle_service_response(response)
          case response.code
          when 200
            JSON.parse(response.body)
          when 400
            {
              :error => {
                :http_code => response.code,
                :http_response_body => JSON.parse(response.body)
              }
            }
            false
          end
        end
      end

      module InstanceMethods
        
      end

      def self.included(receiver)
        receiver.send :include, FCG::Client::Base
        receiver.extend         ClassMethods
        receiver.send :include, InstanceMethods
      end
    end
  end
end