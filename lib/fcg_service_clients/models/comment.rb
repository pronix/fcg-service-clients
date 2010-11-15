module FCG
  module Client
    module Comment
      ATTRIBUTES = [:site, :record, :body, :body_as_html, :deleted, :flagged_by, :depth, :path, :parent_id, :displayed_name, :user_id]

      module ClassMethods

      end

      module InstanceMethods
        protected
        def setup
          self.deleted = false
        end
      end

      def self.included(receiver)

        receiver.extend         ClassMethods
        receiver.send :include, FCG::Client::Persistence
        receiver.send :include, InstanceMethods

        receiver.validates_presence_of :site, :record, :body, :user_id
      end
    end
  end
end