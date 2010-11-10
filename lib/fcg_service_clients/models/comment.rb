module FCG
  module Client
    module Comment
      ATTRIBUTES = [:site, :record, :body, :body_as_html, :deleted, :flagged_by, :depth, :path, :parent_id, :displayed_name, :user_id]

      module ClassMethods
        def all
          request = Typhoeus::Request.new(
            "#{self.service_url}/all",
            :method => :get)

          request.on_complete do |response|
            response
          end

          self.hydra.queue(request)
          self.hydra.run

          handle_service_response request.handled_response
        end
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