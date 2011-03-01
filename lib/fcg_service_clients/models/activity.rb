module FCG
  module Client
    module Activity
      ATTRIBUTES = [:user_id, :extra, :object_type, :object_value, :site, :target, :title, :verb, :page, :city].freeze

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