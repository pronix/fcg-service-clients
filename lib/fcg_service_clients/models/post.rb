module FCG
  module Client
    module Post
      ATTRIBUTES =  [:body, :body_as_html, :created_at, :display_name, :feed_id, :site, :title, :updated_at, :user_id, :username, :version]

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