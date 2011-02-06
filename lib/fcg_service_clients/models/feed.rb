module FCG
  module Client
    module Feed
      ATTRIBUTES = [:created_at, :record, :site, :title, :updated_at, :user_id] 

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