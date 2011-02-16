module FCG
  module Client
    module Rsvp
      ATTRIBUTES = [:bottle_service, :email, :event_id, :message, :name, :number_of_guests, :occassion, :phone, :user_id]
      
      module ClassMethods
        
      end

      module InstanceMethods
        
      end

      def self.included(receiver)
        receiver.extend         ClassMethods
        receiver.send :include, FCG::Client::Persistence
        receiver.send :include, InstanceMethods
        
        receiver.validates_presence_of :name, :number_of_guests, :event_id
        receiver.validates_length_of :message, :allow_nil => true, :in => 1..1000
      end
    end
  end
end