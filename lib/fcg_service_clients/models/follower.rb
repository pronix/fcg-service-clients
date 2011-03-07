module FCG
  module Client
    module Activity
      ATTRIBUTES = [:follower_id, :leader_id, :approved, :created_at, :updated_at].freeze

      module ClassMethods
        
      end

      module InstanceMethods
        
      end

      def self.included(receiver)
        # attr_accessor *ATTRIBUTES
        receiver.extend         ClassMethods
        receiver.send :include, FCG::Client::Persistence
        receiver.send :include, InstanceMethods
      end
    end
  end
end