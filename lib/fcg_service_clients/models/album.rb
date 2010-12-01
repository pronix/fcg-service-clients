module FCG
  module Client
    module Album
      ATTRIBUTES = [:comments_allowed, :created_at, :date, :image_type, :location, :owner_image_count, :owner_images, :owner_images_order, :record, 
        :summary, :title, :total_image_count, :updated_at, :user_id, :user_submitted_image_count, :user_submitted_images, :user_submitted_order]

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