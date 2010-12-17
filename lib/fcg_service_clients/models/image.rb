module FCG
  module Client
    module Image
      ATTRIBUTES = [:album_id, :caption, :created_at, :sizes, :types, :updated_at, :urls, :user_id]

      module ClassMethods
        def find_by_ids(ids)
          request = Typhoeus::Request.new(
            "#{service_url}/by_ids", :params => { :ids => ids.join(",")},
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