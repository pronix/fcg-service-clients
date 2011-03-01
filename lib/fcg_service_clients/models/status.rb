module FCG
  module Client
    module Status
      ATTRIBUTES = [:created_at, :message, :message_as_html, :updated_at, :user_id, :visible].freeze

      module ClassMethods
        
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