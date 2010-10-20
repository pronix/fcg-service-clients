module FCG
  module Client
    module Base
      HYDRA = Typhoeus::Hydra.new
      module ClassMethods
        def search(*args)
          opts = args.extract_options!
          params = {
            :limit => 10,
            :skip => 0
          }.merge(opts)
          
          response = Typhoeus::Request.post("#{service_url}/#{id}", :body => params.to_msgpack)
          handle_service_response(response)
        end
        
        def handle_service_response(response)
          response_body = MessagePack.unpack(response.body)
          case response.code
          when 200
            result = response_body
            if result.is_a? Array
              result.map do |res|
                res.respond_to?(:keys) ? Hashie::Mash.new(res) : res
              end
            else
              result.respond_to?(:keys) ? Hashie::Mash.new(result) : result
            end
            true
          when 400
            {
              :error => {
                :http_code => response.code,
                :http_response_body => response_body
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
          [ self.host, self.model].join("/")
        end
      end
      
      module InstanceMethods
        def to_hash(*args)
          opts = args.extract_options!
          options = {
            :except => []
          }.merge(opts)
          res = self.serializable_hash.inject({}) do |result, (key, value)|
            next if options[:except].include?key
            case value
            when Date, DateTime, Time
              value = value.to_s
            end
            result[key] = value
            result
          end
        end

        def to_msgpack(*args)
          self.to_hash(*args).to_msgpack
        end
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