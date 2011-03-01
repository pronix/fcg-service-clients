module FCG
  module Service
    module Client
      # Sends out the notice to Hoptoad
      class Sender
        HTTP_ERRORS = [Timeout::Error,
                       Errno::EINVAL,
                       Errno::ECONNRESET,
                       EOFError,
                       # Net::HTTPBadResponse,
                       # Net::HTTPHeaderSyntaxError,
                       # Net::ProtocolError,
                       Errno::ECONNREFUSED].freeze

        def initialize(options = {})
          [:proxy_host, :proxy_port, :proxy_user, :proxy_pass, :protocol, :hydra, :api_key,
            :host, :port, :secure, :http_open_timeout, :http_read_timeout].each do |option|
            instance_variable_set("@#{option}", options[option])
          end
        end

        # Sends the notice data off to Hoptoad for processing.
        def send_to_server(*args)
          opts = args.extract_options!
          opts[:headers] = {} unless opts[:headers].is_a?(Hash)
          opts[:params] = {} unless opts[:params].is_a?(Hash)
          params = {
           :api_key => api_key
          }.merge(opts[:params])
          request = Typhoeus::Request.new(url(opts[:path]), 
            :params  => params,
            :timeout => http_read_timeout * 1000, # milliseconds
            :headers => opts[:headers],
            :body => opts[:body],
            :method  => opts[:method])
            
          request.on_complete do |response|
            response
          end

          hydra.queue(request)
          hydra.run

          request
        end

        private
        attr_reader :proxy_host, :proxy_port, :proxy_user, :proxy_pass, :protocol, :hydra, :api_key,
          :host, :port, :secure, :http_open_timeout, :http_read_timeout
          
        def url(path)
          URI.parse("#{protocol}://#{host}:#{port}").merge(path).to_s
        end

        def logger
          LOGGER # HoptoadNotifier.logger
        end
      end
    end
  end
end