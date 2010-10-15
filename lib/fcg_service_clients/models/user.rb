module FCG
  module Client
    module User
      ATTRIBUTES = [:id, :bio, :created_at, :crypted_password, :date_of_birth, :deleted_at, :email, 
        :facebook_id, :facebook_proxy_email, :facebook_session, :flags, :flyers, :last_visited_at, 
        :location, :names, :password, :photo_album, :photo_count, :photos, :posted_party_at, :profile_image, 
        :salt, :sex, :site_specific_settings, :token_expire_at, :token_id, :tokens_expire_at, 
        :twitter_username, :updated_at, :uploaded_photos_at, :username, :web]

      module ClassMethods
        def find_by_facebook_id(facebook_id)
          request = Typhoeus::Request.new(
            "#{self.service_url}/find_by_facebook_id/#{facebook_id}",
            :method => :get)

          request.on_complete do |response|
            handle_service_response(response)
          end

          self.hydra.queue(request)
          self.hydra.run

          request.handled_response
        end

        def find_by_username(username)
          request = Typhoeus::Request.new(
            "#{self.service_url}/find_by_username/#{username}",
            :method => :get)

          request.on_complete do |response|
            handle_service_response(response)
          end

          self.hydra.queue(request)
          self.hydra.run

          request.handled_response
        end

        def find_by_email(email)
          request = Typhoeus::Request.new(
            "#{self.service_url}/find_by_email/#{email}",
            :method => :get)

          request.on_complete do |response|
            handle_service_response(response)
          end

          self.hydra.queue(request)
          self.hydra.run

          request.handled_response
        end

        def encrypt(password, salt)
          Digest::SHA1.hexdigest("-9{-}#{salt}-*-#{password}-215-")
        end

        def authenticate(email_or_username, password, encrypted=true)
          user = case email_or_username
          when REGEX[:email]
            find_by_email(email_or_username)
          else
            find_by_username(email_or_username)
          end
          user and !user.is_a?(Hash) and user.authenticated?(password) && user.flags["enabled"] ? user : nil
        end
      end

      module InstanceMethods
        def display_name
          full_name || username
        end

        def authenticated?(password)
          crypted_password == encrypt(password)
        end

        def encrypt(password)
          self.class.encrypt(password, salt)
        end

        def password_required?
          new_record? || crypted_password.blank? || !password.blank?
        end

        def encrypt_password
          return if password.blank?
          self.salt = Digest::SHA1.hexdigest("--#{username}-#{Guid.new}-email--") if new_record?
          self.crypted_password = encrypt(password)
        end

        # should save async'd
        def logged_in_successfully!
          self.last_visited_at = Time.now.utc
          save
        end

        def promoter?
          !self.posted_party_at.nil? and self.posted_party_at != ""
        end

        def photographer?
          !self.uploaded_photos_at.nil? and self.uploaded_photos_at != ""
        end

        def uploadable_by_user?(user)
          return true if user.id == self.id
        end

        # included from mongo's social plugin
        def user_info
          {
            :id             => self.id,
            :username       => self.username,
            :location       => self.location,
            :display_name   => self.display_name,
            :profile_image  => self.profile_image
          }
        end
        # before_save   :encrypt_password, :set_city_state_using_us_zipcode
        # before_create :setup

        # def save_asynchronous
        #   unless @exchange
        #     @exchange = self.async_client.exchange("users", :type => :topic, :durable => :true)
        #   end
        #   @exchange.publish(to_msgpack, :key => vote)
        # end

        protected
        def setup
          self.location[:country] = "US"
          self.token_id = "#{Time.now.utc.to_i}-#{Guid.new}"
          self.flags = {
            :enabled => true,
            :confirmed => false,
            :keep_profile_private => false
          }
        end
      end

      def self.included(receiver)
        attr_accessor *ATTRIBUTES
        receiver.extend         ClassMethods
        receiver.send :include, FCG::Client::Persistence
        receiver.send :include, InstanceMethods
        receiver.send :include, FCG::UserIncludable

        receiver.validates_length_of :username, :within => 4..16
        receiver.validates_length_of :email, :within => 6..100
        receiver.validates_format_of :email, :with => REGEX[:email]
        receiver.validates_format_of :username, :with => REGEX[:username]
        receiver.validates_length_of :password, :within => 6..24, :if => :password_required?
      end
    end
  end
end