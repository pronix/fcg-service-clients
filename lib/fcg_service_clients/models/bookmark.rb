module FCG
  module Client
    module Bookmark
      ATTRIBUTES = [:user_id, :title, :path, :bookmark_type].freeze

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