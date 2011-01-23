module FCG
  module Client
    module Site
      ATTRIBUTES = [:url, :name, :extra, :cities, :active_cities_sorted]

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