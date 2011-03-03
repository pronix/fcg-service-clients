module FCG
  module Client
    module JobState
      ATTRIBUTES = [:created, :cloud_crowd_id, :job_hash, :polled, :result, :state, :site, :updated].freeze

      module ClassMethods
      end

      module InstanceMethods
        def complete?
          self.state == "completed"
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
            :job_hash => self.job_hash,
            :cloud_crowd_id => self.cloud_crowd_id,
            :job_hash => self.job_hash,
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
        receiver.validates_presence_of :type, :cloud_crowd_id
      end
    end
  end
end