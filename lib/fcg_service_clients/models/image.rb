module FCG
  module Client
    module Image
      ATTRIBUTES = [:album_id, :caption, :created_at, :sizes, :types, :updated_at, :urls, :user_id]

      module ClassMethods
        
      end

      module InstanceMethods
        
      end

      def self.included(receiver)

        receiver.extend         ClassMethods
        receiver.send :include, FCG::Client::Persistence
        receiver.send :include, InstanceMethods
        receiver.validates_presence_of :user_id, :types, :urls, :sizes, :album_id
      end
    end
  end
end