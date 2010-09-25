module FCG
  module Client
    HYDRA = Typhoeus::Hydra.new
    module ClassMethods
      def create(record)
        Typhoeus::Request.new(
          "#{self.host}/api/#{self.version}/#{self.model}",
          :method => :post, :body => record.to_json(:except => [:id, :created_at, :updated_at]))
      end

      def update(record)
        Typhoeus::Request.new(
          "#{self.host}/api/#{self.version}/#{self.model}/#{record.id}",
          :method => :put, :body => record.to_json)
      end
      
      def find(id)
        request = Typhoeus::Request.new(
          "#{self.host}/api/#{self.version}/#{self.model}/#{id}",
          :method => :get)
        request.on_complete do |response|
          handle_service_response(response)
        end

        self.hydra.queue(request)
        self.hydra.run

        request.handled_response
      end
      
      def delete(id)
        request = Typhoeus::Request.new(
          "#{self.host}/api/#{self.version}/#{self.model}/#{id}",
          :method => :delete)
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
          new(JSON.parse(response.body))
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
      def initialize(attributes_or_json = {})
        from_json(attributes_or_json) if attributes_or_json.is_a? String
        self.attributes = attributes_or_json.respond_to?(:to_mash) ? attributes_or_json.to_mash : attributes_or_json
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
        attrs.each_pair do |name, value| 
          begin
            send("#{name}=", value)
          rescue NoMethodError
            puts "#{name} is missing"
          end
        end
      end

      def read_attribute_for_validation(key)
        send(key)
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
      
      private
      def handle_service_response(response)
        case response.code
        when 200
          attributes_as_json = JSON.parse(response.body)
          self.attributes = attributes_as_json.respond_to?(:to_mash) ? attributes_as_json.to_mash : attributes_as_json
          true
        when 400
          response_body_parsed = JSON.parse(response.body)
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
          request = self.class.create(self)
          request.on_complete do |response|
            handle_service_response(response)
          end

          self.class.hydra.queue(request)
          self.class.hydra.run
          request.handled_response
        end
      end
      
      def update
        _run_update_callbacks do
          request = self.class.update(self)
          request.on_complete do |response|
            handle_service_response(response)
          end

          self.class.hydra.queue(request)
          self.class.hydra.run
          request.handled_response
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
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
      receiver.send :include, ClassLevelInheritableAttributes
      receiver.cattr_inheritable :host, :hydra, :model, :version, :async_client
    end
  end
end