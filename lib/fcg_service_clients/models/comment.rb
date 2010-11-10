module FCG
  module Client
    module Comment
      ATTRIBUTES = [:site, :record, :body, :body_as_html, :deleted, :flagged_by, :depth, :path, :parent_id, :displayed_name, :user_id]

      module ClassMethods
        def find_by_record(record)
          request = Typhoeus::Request.new(
            "#{self.service_url}/find_by_record/#{record}",
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
        def comment_info
          {
            :id => self.id,
            :site => self.site,
            :record => self.record,
            :body => self.body,
            :body_as_html => self.body_as_html,
            :flagged_by => self.flagged_by,
            :depth  => self.depth,
            :path => self.path,
            :parent_id  => self.parent_id,
            :displayed_name => self.displayed_name,
            :user_id  => self.user_id
          }
        end

        protected
        def setup
          self.deleted = false
        end
      end

      def self.included(receiver)

        receiver.extend         ClassMethods
        receiver.send :include, FCG::Client::Persistence
        receiver.send :include, InstanceMethods

        receiver.validates_presence_of :site
        receiver.validates_presence_of :record
        receiver.validates_presence_of :body
        receiver.validates_presence_of :user_id
      end
    end
  end
end