module FCG
  module Client
    module Base
      HYDRA = Typhoeus::Hydra.new
      
      class FailedConnectionException < RuntimeError
      end
      
      class ServiceCodeException < RuntimeError
      end
      
      module ClassMethods
        def search(*args)
          opts = args.extract_options!
          params = {
            :limit => 10,
            :skip => 0
          }.merge(opts)
          
          request = Typhoeus::Request.new(
            "#{service_url}/search", :body => hash_to_msgpack(params),
            :method => :post)
          request.on_complete do |response|
            response
          end

          self.hydra.queue(request)
          self.hydra.run

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
            instance_variable_set("@model", self.name.downcase.pluralize) if instance_variable_get("@model").nil?
          end
        end
        
        def service_url
          [ self.host, self.model].join("/")
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

        # def to_msgpack(*args)
        #   self.class.hash_to_msgpack(self.to_hash, *args)
        # end
        
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
        attr_accessor :attributes_original
      end
    end
  end
end