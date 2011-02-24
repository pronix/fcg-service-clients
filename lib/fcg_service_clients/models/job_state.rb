module FCG
  module Client
    module JobState
      ATTRIBUTES = [:created, :crowd_cloud_hash, :crowd_cloud_id, :job_hash, :polled, :result, :state, :site, :updated]

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
            :crowd_cloud_id => self.crowd_cloud_id,
            :crowd_cloud_hash => self.crowd_cloud_hash,
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
        receiver.validates_presence_of :type, :crowd_cloud_id
      end
    end
  end
end