module FCG
  module Service
    module Client
      class << self
        attr_accessor :sender
        attr_accessor :configuration
        def configure(silent = false)
          self.configuration ||= Configuration.new
          yield(configuration)
          self.sender = Sender.new(configuration)
        end
      end
    end
  end
end