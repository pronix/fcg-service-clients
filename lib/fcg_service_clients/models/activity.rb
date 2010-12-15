module FCG
  module Client
    module Activity
      ATTRIBUTES = [:user_id, :created_at, :extra, :object_type, :object_id, :site, :target, :title, :verb, :page, :city]

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