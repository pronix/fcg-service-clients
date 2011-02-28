module FCG
  module Client
    module Rating
      ATTRIBUTES = [:created_at, :record, :score, :updated_at, :user_id]

      module ClassMethods
        def by_record(record, *args)
          record = "#{record.class}:#{record.id}" unless record.is_a?(String)
          params = args.extract_options!
          request = send_to_server(:method => :get, :path => "#{service_url}/record/#{record}", :params => params)
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