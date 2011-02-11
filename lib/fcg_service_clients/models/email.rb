module FCG
  module Client
    module Email
      ATTRIBUTES = [:to, :from, :site, :body, :subject]

      module ClassMethods
        def deliver(*args)
          params = args.extract_options!
          
          request = Typhoeus::Request.new(
            "#{service_url}/deliver",
            :method => :post, :body => params.to_msgpack )
          
          request.on_complete do |response|
            handle_service_response(response)
          end

          hydra.queue(request)
          hydra.run

          request.handled_response
        end
      end

      def self.included(receiver)
        receiver.send :include, FCG::Client::Base
        receiver.extend         ClassMethods
      end
    end
  end
end