module FCG
  module Client
    module Authenticator
      ATTRIBUTES = [:id, :user_id, :uid, :provider].freeze

      module ClassMethods
        def find_by_provider_and_uid(provider,uid)
          request = send_to_server(:method => :get, :path => "#{self.service_url}/find_by_provider_and_uid/#{provider}/#{uid}")
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
