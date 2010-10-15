require "facets/uri"

module FCG
  module Client
    module Base
      HYDRA = Typhoeus::Hydra.new
      module ClassMethods
        def search(*args)
          opts = args.extract_options!
          params = {
            :limit => 10,
            :offset => 0
          }.merge(opts)
          
          verb = "search"
          request = Typhoeus::Request.new(
            "#{service_url}/#{verb}?" + params.to_uri,
            :method => :get)
          
          request.on_complete do |response|
            handle_service_response(response)
          end

          self.hydra.queue(request)
          self.hydra.run

          request.handled_response
        end
        
        def handle_service_response(response)
          case response.code
          when 200
            result = MessagePack.unpack(response.body)
            result.respond_to?(:keys) ? Hashie::Mash.new(result) : result
          when 400
            {
              :error => {
                :http_code => response.code,
                :http_response_body => MessagePack.unpack(response.body)
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