module FCG
  module Client
    module Persistence
      module ClassMethods
        def create(record)
          request = Typhoeus::Request.new(
            service_url,
            :method => :post, :body => record.to_msgpack(:except => [:id, :created_at, :updated_at]))
          request.on_complete do |response|
            response
          end

          self.hydra.queue(request)
          self.hydra.run
          
          request.handled_response
        end

        def update(record)
          request = Typhoeus::Request.new(
            "#{service_url}/#{record.id}",
            :method => :put, :body => record.diff_as_msgpack)
          request.on_complete do |response|
            response
          end

          self.hydra.queue(request)
          self.hydra.run
          
          request.handled_response
        end

        def find(id)
          request = Typhoeus::Request.new(
            "#{service_url}/#{id}",
            :method => :get)
          request.on_complete do |response|
            response
          end

          self.hydra.queue(request)
          self.hydra.run

          handle_service_response request.handled_response
        end

        def delete(id)
          request = Typhoeus::Request.new(
            "#{service_url}/#{id}",
            :method => :delete)
          request.on_complete do |response|
            response
          end

          self.hydra.queue(request)
          self.hydra.run

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
          @attributes ||= const_get('ATTRIBUTES' )
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
          self.attributes = attributes_or_msgpack.respond_to?(:to_mash) ? attributes_or_msgpack.to_mash : attributes_or_msgpack
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
            result[key] = value_for_hash(value)
            result
          end
          hash.to_msgpack
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
      end
    end
  end
end