module FCG
  module Client
    module Activity
      ATTRIBUTES = [:actor, :created_at, :extra, :id, :object, :site, :summary, :target, :title, :verb]

      module ClassMethods

      end

      module InstanceMethods

      end

      def self.included(receiver)
        attr_accessor *ATTRIBUTES
        receiver.extend         ClassMethods
        receiver.send :include, FCG::Client
        receiver.send :include, InstanceMethods
        # receiver.include_root_in_json = false
      end
    end
  end
end