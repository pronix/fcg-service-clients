module FCG
  module Client
    module JobState
      ATTRIBUTES = [:created, :error_message, :job_id, :polled, :result, :state, :time_hash, :type, :updated]

      module ClassMethods
        def create_new_job_with_id!(id, type)
          js = create :job_id => id, :type => type, :state => "started", :time_hash => "{}", :error_message => "[]", :created_at => Time.now.w3c
        end

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
        def image
          @image ||= Image.by_job_id(job_id).first
        end

        def complete?
          return false if self.errors_exist?
          return true if self.state == "completed"
          case self.type
          when "User", "Flyer", "Event"
            self.completed! if image and image.check_if_completed?
          end
          self.state == "completed"
        end

        def completed!
          self.state = "completed"
          self.save
        end
        
        def polled!
          self.polled = self.polled.to_i + 1
          self.save
        end
        
        def as_json(*args)
          {
            :job_id => self.job_id,
            :error_message => JSON.parse(self.error_message),
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
      end
    end
  end
end