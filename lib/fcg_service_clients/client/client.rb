module FCG
  module Client
    module Base      
      class FailedConnectionException < RuntimeError
      end
      
      class ServiceCodeException < RuntimeError
      end
      
      module ClassMethods
        def send_to_server(*args)
          FCG::Service::Client.sender.send_to_server(*args)
        end
        
        def search(*args)
          opts = args.extract_options!
          params = {
            :limit => 10,
            :skip => 0
          }.merge(opts)
          
          params[:conditions] = params[:conditions].inject({}) do |result, (key, value)|
            case value
            when Range
              result["#{key}.gte".to_sym], result["#{key}.lte".to_sym] = value.first, value.last
            else
              result[key] = value
            end
            result
          end unless params[:conditions].nil?

          request = send_to_server(:method => :get, :params => params, :path => "#{service_url}/search")
          handle_service_response request.handled_response
        end

        def regex(*args)
          opts = args.extract_options!
          params = {
            :limit => 10,
            :skip => 0
          }.merge(opts)

          params[:conditions] = params[:conditions].inject({}) do |result, (key, value)|
            case value
            when Range
              result["#{key}.gte".to_sym], result["#{key}.lte".to_sym] = value.first, value.last
            else
              result[key] = value
            end
            result
          end unless params[:conditions].nil?

          request = send_to_server(:method => :get, :params => params, :path => "#{service_url}/regex")
          handle_service_response request.handled_response
        end

        def count(*args)
          opts = args.extract_options!
          params = opts

          params[:conditions] = params[:conditions].inject({}) do |result, (key, value)|
            case value
            when Range
              result["#{key}.gte".to_sym], result["#{key}.lte".to_sym] = value.first, value.last
            else
              result[key] = value
            end
            result
          end unless params[:conditions].nil? || params[:conditions].empty?
          
          request = send_to_server(:method => :get, :params => params, :path => "#{service_url}/count")
          handle_service_response request.handled_response
        end
        
        def handle_service_response(response)
          begin
            response_body = MessagePack.unpack(response.body)
          rescue MessagePack::UnpackError => e
            response_body = []
          end
          case response.code
          when 200
            result = response_body
            if result.is_a? Array
              result.map do |res|
                res.respond_to?(:keys) ?  Hashie::Mash.new(res) : res
              end
            else
              result.respond_to?(:keys) ? Hashie::Mash.new(result) : result
            end
          when 400
            {
              :error => {
                :http_code => response.code,
                :http_response_body => response_body
              }
            }
          when 500
            log [ServiceCodeException, response.body, caller].join(" ")
          end
        end
        
        def setup_service(*args)
          args.each do |arg| 
            arg.each_pair do |key, value| 
              class_eval{ instance_variable_set("@#{key}", value) }
            end 
          end
          class_eval do
            instance_variable_set("@model", self.name.snakecase.pluralize) if instance_variable_get("@model").nil?
          end
        end
        
        def service_url
          "/" + self.model # [ self.host, self.model].join("/")
        end
        
        def serializable_hash(hash, *args)
          opts = args.extract_options!
          options = {
            :except => []
          }.merge(opts)
          hash.inject({}) do |result, (key, value)|
            next if options[:except].include? key
            result[key] = value_for_hash(value)
            result
          end
        end
        
        [:json, :xml, :msgpack].each do |format|
          define_method("hash_to_#{format}".to_sym) do |hash, *args|
            hash = self.serializable_hash(hash, *args)
            hash.send "to_#{format}"
          end
        end
        
        def value_for_hash(value)
          case value
          when Date, DateTime, Time
            value.to_s
          when Range
            [value.first, value.last].map(&:to_s).join("..")
          when Hash
            serializable_hash(value)
          else
            value
          end
        end
        
        protected
        # from rails 3
        def generated_attribute_methods #:nodoc:
          @generated_attribute_methods ||= begin
            mod = Module.new
            include mod
            mod
          end
        end
        
        def define_method_attribute=(attr_name)
          generated_attribute_methods.module_eval("def #{attr_name}=(new_value); write_attribute('#{attr_name}', new_value); end", __FILE__, __LINE__)
        end
        
        def define_method_attributes=(attr_names)
          attr_names.each{|attr_name| define_method_attribute(attr_name) }
        end
      end
      
      module InstanceMethods
        def to_hash(*args)
          opts = args.extract_options!
          options = {
            :except => []
          }.merge(opts)
          res = self.serializable_hash.inject({}) do |result, (key, value)|
            next if options[:except].include? key
            result[key] = self.class.value_for_hash(value)
            result
          end
        end
        
        [:json, :xml, :msgpack].each do |format|
          define_method("to_#{format}".to_sym) do |*args|
            self.class.send "hash_to_#{format}", self.to_hash, *args
          end
        end
      end
      
      def self.included(receiver)
        receiver.extend         ClassMethods
        receiver.send :include, InstanceMethods
        receiver.send :include, ClassLevelInheritableAttributes
        receiver.cattr_inheritable :host, :hydra, :model, :version, :async_client
        receiver.include_root_in_json = false if receiver.respond_to? :include_root_in_json
        receiver.setup_service(
          :hydra => FCG::Service::Client.configuration.hydra, 
          :host => FCG::Service::Client.configuration.host + ":" + FCG::Service::Client.configuration.port.to_s, 
          :async_client => FCG::Service::Client.configuration.async_client
        )
        attr_accessor :attributes_original, :raw_attributes
      end
    end
  end
end