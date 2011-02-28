module FCG
  module Client
    module Region
      ATTRIBUTES = [:active, :country, :created_at, :full_name, :short_name, :tags, :updated_at, :zipcodes]

      module ClassMethods
        def find_by_site(site, *args)
          opts = args.extract_options!
          params = {
            :active => true,
            :limit => 25,
            :skip => 0
          }.merge(opts)
          request = send_to_server(:method => :get, :path => "#{service_url}/by_site/#{site}", :params => params)
          handle_service_response request.handled_response
        end
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