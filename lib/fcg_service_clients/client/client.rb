module FCG
  module Client
    HYDRA = Typhoeus::Hydra.new
    module Base
      module ClassMethods
        def handle_service_response(response)
          case response.code
          when 200
            Hashie::Mash.new(JSON.parse(response.body))
          when 400
            {
              :error => {
                :http_code => response.code,
                :http_response_body => JSON.parse(response.body)
              }
            }
            false
          end
        end
        
        def setup_service(*args)
          args.each do |arg| 
            arg.each_pair do |key, value| 
              class_eval{ instance_variable_set("@#{key}", value) }
            end 
          end
          class_eval do
            instance_variable_set("@model", self.name.downcase.pluralize) if instance_variable_get("@model").nil?
          end
        end
        
        def service_url
          [ self.host, "api", self.version, self.model].join("/")
        end
      end
      
      module InstanceMethods
        
      end
      
      def self.included(receiver)
        receiver.extend         ClassMethods
        receiver.send :include, InstanceMethods
        receiver.send :include, ClassLevelInheritableAttributes
        receiver.cattr_inheritable :host, :hydra, :model, :version, :async_client
      end
    end
  end
end