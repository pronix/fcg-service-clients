module FCG
  module Client
    module Twitter
      ATTRIBUTES = [:id].freeze

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