module FCG
  module Client
    module Fetcher
      module ClassMethods
        
      end

      module InstanceMethods
        
      end

      def self.included(receiver)
        receiver.send :include, FCG::Client::Base
        receiver.extend         ClassMethods
        receiver.send :include, InstanceMethods
      end
    end
  end
end