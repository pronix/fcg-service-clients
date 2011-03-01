module FCG
  module Client
    module Geo
      ATTRIBUTES = [:country, :zipcode, :packed, :msa, :us_state, :us_areacode].freeze

      module ClassMethods

      end

      module InstanceMethods
        
      end

      def self.included(receiver)
        # attr_accessor *ATTRIBUTES
        receiver.extend         ClassMethods
        receiver.send :include, FCG::Client::Persistence
        receiver.send :include, InstanceMethods
      end
    end
  end
end