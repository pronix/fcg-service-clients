module FCG
  module Client
    module Party
      ATTRIBUTES = [:active, :comments_allowed, :created_at, :days_free, :days_left, :days_paid, :deleted, :description, :dj, :door_charge_in_cents, :end_date, :end_time, :events, :guestlist_in_cents, :hide_guestlist, :host, :length_in_hours, :music, :next_date, :photographer_list, :pictures_left, :post_updates_to_twitter, :premium, :private, :recur, :rsvp_email, :start_time, :title, :updated_at, :url, :user_id, :venue]

      module ClassMethods
        
      end

      module InstanceMethods
        def weekly
          recur == "weekly"
        end

        def weekly=(val)
          if val.to_i == 1
            self.recur = "weekly"
          else
            self.recur = "once"
          end
        end

        def venue_name
          venue[:name]
        end

        def next_date=(val)
          write_attribute(:next_date, Date.parse(val))
        end

        def current_event
          return nil if current_event_id.nil?
          Event.find(current_event_id)
        end

        def current_event_id
          events["#{next_date}"]
        end

        def create_current_event
          event = Event.create_based_on_party(self) if current_event.nil? 
        end

        def venue_id=(val)
          v = Venue.find(val.to_s)
          self.venue = v.to_hash
        end

        # def to_param
        #   %Q{#{id}-#{[title, venue.name, venue.city, venue.state].join(' ').gsub(/[^a-z0-9]+/i, '_')}}
        # end

        def get_length_in_hours
          start_t = Time.parse("#{self.next_date} #{self.start_time}") 
          end_t = Time.parse("#{self.next_date} #{self.end_time}")
          case start_t <=> end_t
            when 1
              (24 - (start_t - end_t) / 3600 ).to_f
            when -1
              ((start_t - end_t) / 3600 ).to_f.abs
            when 0
              24
          end
        end

        def events_as_id_hashes
          events.inject({}) do |sum, (key, value)|
            sum[key.to_s] = value.to_s
            sum
          end
        end

        def uploadable_by_user?(user)
          return true if user.id == self.user_id or photographer_list.include?("email:#{user.email}") or photographer_list.include?("username:#{user.username}")
          false
        end
      end

      def self.included(receiver)
        attr_accessor *ATTRIBUTES
        receiver.extend         ClassMethods
        receiver.send :include, FCG::Client::Persistence
        receiver.send :include, InstanceMethods
      end
    end
  end
end