module FCG
  module Client
    module Rating
      ATTRIBUTES = [:created_at, :record, :score, :updated_at, :user_id]

      module ClassMethods
        def by_record(record_id, *args)
          params = args.extract_options!
          request = Typhoeus::Request.new(
            "#{service_url}/record/#{record_id}", :params => params,
            :method => :get)
          request.on_complete do |response|
            response
          end

          self.hydra.queue(request)
          self.hydra.run


          handle_service_response_for_by_record request.handled_response
        end

        def handle_service_response_for_by_record(response)
          case response.code
          when 200
            MessagePack.unpack(response.body).recursive_symbolize_keys!
          when 400
            {
              :error => {
                :http_code => response.code,
                :http_response_body => MessagePack.unpack(response.body)
              }
            }
            false
          end
        end
      end

      module InstanceMethods
        
      end

      def self.included(receiver)
        receiver.extend         ClassMethods
        receiver.send :include, FCG::Client::Persistence
        receiver.send :include, InstanceMethods
      end
    end
  end
end