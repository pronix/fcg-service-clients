module FCG
  module Client
    module Image
      ATTRIBUTES = [:album_id, :caption, :created_at, :deleted_at, :job_id, :size, :state, :types, :updated_at, :url, :user_id] 

      module ClassMethods
        
      end

      module InstanceMethods
        
      end

      def self.included(receiver)
#         attr_accessor *ATTRIBUTES
        receiver.extend         ClassMethods
        receiver.send :include, FCG::Client::Persistence
        receiver.send :include, InstanceMethods
      end
    end
  end
end