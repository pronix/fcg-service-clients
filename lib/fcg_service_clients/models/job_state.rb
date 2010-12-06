module FCG
  module Client
    module JobState
      ATTRIBUTES = [:created, :polled, :result, :site, :state, :time_hash, :updated]

      module ClassMethods
        def update!(values_as_hash)
          js = self[values_as_hash["callback"]["job_state_id"]]
          js.error_message = values_as_hash["errors"].to_json unless values_as_hash["errors"].empty?
          js.result = values_as_hash["callback"].to_json
          if values_as_hash["callback"].has_key? "suffix"
            # js.time_hash = "{}" if js.time_hash.nil? or js.time_hash == ""
            js.time_hash = JSON.parse(js.time_hash).merge({
              values_as_hash["callback"]["suffix"] => values_as_hash["time"]
            }).to_json
          else
            js.time_hash = {
              "default" => values_as_hash["time"]
            }.to_json
          end
          js.state = "completed" if js.complete?
          js.save
        end
      end

      module InstanceMethods
        def complete?
          return true if self.state == "completed"
          false
        end

        def completed!
          # should be done async
          self.state = "completed"
          self.save
        end
        
        def polled!
          # should be done async
          self.polled = polled + 1
          self.save
        end
        
        def as_json(*args)
          {
            :time_hash => self.time_hash,
            # :error_message => JSON.parse(self.error_message),
            :state => self.state,
            :type => self.type,
            :polled => self.polled
          }
        end
      end

      def self.included(receiver)
        receiver.extend         ClassMethods
        receiver.send :include, FCG::Client::Persistence
        receiver.send :include, InstanceMethods
        receiver.validates_presence_of :type, :site
      end
    end
  end
end