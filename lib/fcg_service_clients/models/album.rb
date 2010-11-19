module FCG
  module Client
    module Album
      ATTRIBUTES = [:created_at, :date, :description, :image_type, :location, :owner_image_count, :owner_images, :record, :title, :total_image_count, :updated_at, 
        :user_id, :user_submitted_image_count, :user_submitted_images]

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