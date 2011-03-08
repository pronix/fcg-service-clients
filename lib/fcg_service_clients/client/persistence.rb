module FCG
  module Client
    module Persistence
      module ClassMethods
        def create(record)
          request = send_to_server(:method => :post, :body => hash_to_msgpack(record.to_hash, :except => [:id, :created_at, :updated_at]), :path => service_url)
          request.handled_response
        end

        def update(record)
          request = send_to_server(:method => :put, :body => record.diff_as_msgpack, :path => "#{service_url}/#{record.id}")
          request.handled_response
        end

        def find(id)
          request = send_to_server(:method => :get, :path => "#{service_url}/#{id}")
          handle_service_response request.handled_response
        end

        def delete(id)
          request = send_to_server(:method => :delete, :path => "#{service_url}/#{id}")
          handle_service_response request.handled_response
        end

        def handle_service_response(response)
          result = MessagePack.unpack(response.body)
          case response.code
          when 200
            if result.is_a? Array
              result.map{|res| new(res) }
            else
              new(result)
            end
          when 400
            {
              :error => {
                :http_code => response.code,
                :http_response_body => result
              }
            }
          end
        end

        def attributes
          raise "Missing ATTRIBUTES" unless defined? :ATTRIBUTES
          @attributes ||= [:id] + const_get('ATTRIBUTES')
        end

        def column_names
          attributes
        end

        def human_name
          self.name.demodulize.titleize
        end
      end

      module InstanceMethods
        def initialize(attributes_or_msgpack = {})
          self.raw_attributes = attributes_or_msgpack.respond_to?(:to_mash) ? attributes_or_msgpack.to_mash : attributes_or_msgpack
          self.attributes = self.raw_attributes
          self.attributes_original = self.attributes.clone
          @errors = ActiveModel::Errors.new(self)
          @new_record = (self.id.nil? ? true :false)
          @_destroyed = false
          self
        end

        def attributes
          self.class.attributes.inject(Hashie::Mash.new) do |result, key|
            result[key] = read_attribute_for_validation(key)
            result
          end
        end

        def attributes=(attrs)
          attrs.each_pair do |key, value| 
            begin
              write_attribute_for_validation(key, value) if respond_to?("#{key}=")
            rescue NoMethodError
              puts "#{key} is missing"
            end
          end
        end

        def read_attribute_for_validation(key)
          send(key)
        end
        
        def write_attribute_for_validation(key, value)
          self.raw_attributes[key] = value
          send("#{key}=", value)
        end
        
        def save(*)
          if valid?
            _run_save_callbacks do
              create_or_update
            end
          else
            false
          end
        end

        def to_param
          id.to_s
        end

        def to_key
          persisted? ? [id.to_s] : nil
        end

        def to_model
          self
        end

        def new_record?
          @new_record
        end

        def persisted?
          !(new_record? || destroyed?)
        end

        def destroyed?
          @_destroyed == true
        end

        def errors
          @errors ||= ActiveModel::Errors.new(self)
        end

        def delete
          _run_delete_callbacks do
            @_destroyed = true
            self.class.delete(id) unless new_record?
          end
        end

        def destroy
          _run_delete_callbacks do
            @_destroyed = true
            self.class.delete(id) unless new_record?
          end
        end

        def reload
          unless new_record?
            self.class.find(self.id)
          end
          self
        end
        
        def diff
          self.attributes.diff(self.attributes_original)
        end
        
        def diff_as_msgpack
          hash = diff.inject({}) do |result, (key, value)|
            result[key] = self.class.value_for_hash(value)
            result
          end
          hash.to_msgpack
        end
        
        def model_with_id(separator=":")
          [self.class, self.id].join(separator)
        end
        
        private
        def handle_service_response(response)
          case response.code
          when 200
            attribute_as_msgpack = MessagePack.unpack(response.body)
            self.attributes = attribute_as_msgpack.respond_to?(:to_mash) ? attribute_as_msgpack.to_mash : attribute_as_msgpack
            true
          when 400..499
            response_body_parsed = MessagePack.unpack(response.body)
            response_body_parsed["errors"].each_pair do |key, values|
              values.compact.each{|value| errors.add(key.to_sym, value) }
            end
            false
          end
        end

        def create_or_update
          new_record? ? create : update
        end

        def create
          _run_create_callbacks do
            response = self.class.create(self)
            handle_service_response(response)
          end
        end

        def update
          _run_update_callbacks do
            response = self.class.update(self)
            handle_service_response(response)
          end
        end
      end

      def self.included(receiver)
        if defined?(ActiveModel)
          receiver.extend         ActiveModel::Naming
          receiver.extend         ActiveModel::Callbacks
          receiver.send :include, ActiveModel::Dirty
          receiver.send :include, ActiveModel::Validations
          receiver.send :include, ActiveModel::Serializers::JSON
          receiver.define_model_callbacks :create, :update, :save, :delete
        end
        receiver.send :include, FCG::Client::Base
        receiver.extend         ClassMethods
        receiver.send :include, InstanceMethods
        attr_accessor *receiver.attributes
      end
    end
  end
end