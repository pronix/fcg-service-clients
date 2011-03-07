module FCG
  module Client
    module Status
      ATTRIBUTES = [:created_at, :message, :message_as_html, :updated_at, :user_id, :visible].freeze

      module ClassMethods
        def leaders_status(follower_id, *args)
          opts = args.extract_options!
          params = {

            :limit => 10,
            :skip => 0
          }.merge(opts)
          request = send_to_server(:method => :get, :path => "#{service_url}/#{follower_id}/leaders/status", :params => params)
          handle_service_response request.handled_response
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