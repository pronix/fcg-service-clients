module FCG
  module Client
    module ObjectSummary
      ATTRIBUTES = [:object_type,
                    :object_id,
                    :minute, :minute_updated,
                    :hour, :hour_updated,
                    :day, :day_updated,
                    :week, :week_updated,
                    :month, :month_updated,
                    :year, :year_updated,
                    :all]

      module ClassMethods
        def get_summaries(type, order)
          params = {
            :order => order
          }
          request = Typhoeus::Request.new(
            "#{service_url}/" + type.pluralize, :params => params,
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
        # attr_accessor *ATTRIBUTES
        receiver.extend         ClassMethods
        receiver.send :include, FCG::Client::Persistence
        receiver.send :include, InstanceMethods
      end
    end
  end
end