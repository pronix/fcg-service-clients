module FCG
  module Client
    module Comment
      ATTRIBUTES = [:site, :record, :body, :body_as_html, :deleted, :flagged_by, :depth, :path, :parent_id, :displayed_name, :user_id]

      module ClassMethods
        def count(*args)
          opts = args.extract_options!
          request = Typhoeus::Request.new(
            "#{service_url}/count", :body => hash_to_msgpack(opts),
            :method => :post)
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