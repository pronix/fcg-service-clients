# heavily inspired by Hoptoad's HoptoadNotifier
module FCG
  module Service
    module Client
      # Used to set up and modify settings for the FCG Service Client.
      class Configuration
        OPTIONS = [:api_key, :async_client, :development_environments, 
          :development_lookup, :environment_name, :host, 
          :http_open_timeout, :http_read_timeout, :hydra, :port, 
          :project_root, :protocol, :proxy_host, :proxy_pass, :proxy_port, 
          :proxy_user, :secure ].freeze

        # The API key for your project, found on the project edit form.
        attr_accessor :api_key

        # The host to connect to (defaults to service.fcgmedia.com)
        attr_accessor :host

        # program used to fetch data
        attr_accessor :hydra

        # program used to save data asynchronously
        attr_accessor :async_client

        # connections, 80 for insecure connections).
        attr_accessor :port

        # +true+ for https connections, +false+ for http connections.
        attr_accessor :secure

        # The HTTP open timeout in seconds (defaults to 2).
        attr_accessor :http_open_timeout

        # The HTTP read timeout in seconds (defaults to 5).
        attr_accessor :http_read_timeout

        # The hostname of your proxy server (if using a proxy)
        attr_accessor :proxy_host

        # The port of your proxy server (if using a proxy)
        attr_accessor :proxy_port

        # The username to use when logging into your proxy server (if using a proxy)
        attr_accessor :proxy_user

        # The password to use when logging into your proxy server (if using a proxy)
        attr_accessor :proxy_pass

        # A list of environments in which notifications should not be sent.
        attr_accessor :development_environments

        # +true+ if you want to check for production errors matching development errors, +false+ otherwise.
        attr_accessor :development_lookup

        # The name of the environment the application is running in
        attr_accessor :environment_name

        # The path to the project in which the error occurred, such as the RAILS_ROOT
        attr_accessor :project_root

        # The logger used by FCG::Service::Client
        attr_accessor :logger

        alias_method :secure?, :secure

        def initialize
          @secure                   = false
          @host                     = 'service.fcgmedia.com'
          @http_open_timeout        = 2
          @http_read_timeout        = 5
          @hydra                    = Typhoeus::Hydra.new
          @async_client             = false
          @development_environments = %w(development test cucumber)
          @development_lookup       = true
        end

        # Allows config options to be read like a hash
        #
        # @param [Symbol] option Key for a given attribute
        def [](option)
          send(option)
        end

        # Returns a hash of all configurable options
        def to_hash
          OPTIONS.inject({}) do |hash, option|
            hash.merge(option.to_sym => send(option))
          end
        end

        # Returns a hash of all configurable options merged with +hash+
        #
        # @param [Hash] hash A set of configuration options that will take precedence over the defaults
        def merge(hash)
          to_hash.merge(hash)
        end

        # Determines if the notifier will send notices.
        # @return [Boolean] Returns +false+ if in a development environment, +true+ otherwise.
        def public?
          !development_environments.include?(environment_name)
        end

        def port
          @port || default_port
        end

        def protocol
          if secure?
            'https'
          else
            'http'
          end
        end

        private
        def default_port
          if secure?
            443
          else
            80
          end
        end
      end
    end
  end
end