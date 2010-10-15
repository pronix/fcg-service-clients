module FCG
  module Client
    module Event
      ATTRIBUTES = [:id, :active, :comments_allowed, :created_at, :date, :deleted_at, :description, :dj, :end_time, :end_time_utc, :flyer_album, :flyers, :host, 
        :length_in_hours, :music, :party_id, :photo_album, :photos, :posted_to_twitter_at, :start_time, :start_time_utc, :title, :updated_at, :user_id, 
        :venue, :version]

      module ClassMethods
        def upcoming_the_next_7_days
          now = 6.hours.ago(Time.now.utc)
          date_range = now.beginning_of_day..7.days.since(now).end_of_day
          search(:active => true, :start_date => date_range.first.to_i, :end_date => date_range.last.to_i)
        end
      end

      module InstanceMethods
        def photo_album_title
          txt = date.short_date + ": #{title_and_venue_name}"
          txt << " (#{photo_album[:title]})" if photo_album[:title]
          txt
        end

        def cover_image
          Image.find(photos_sorted.first) unless photos.empty?
        end

        def update_from_party(party, new_date)
          self.party  = party
          self.date = new_date
          set_utc(party.date, party.start_time, party.length_in_hours)
        end

        def parse_time(date_time)
          Time.parse date_time.to_s
        end

        def set_utc(date, start_time, hrs)
          raw_start_time = parse_time( date.to_s + " " + start_time )
          end_date_time = hrs.to_i.hours.since(raw_start_time)
          write_attribute(:start_time_utc, raw_start_time.local_to_utc( time_zone ))
          raw_end_time_utc = end_date_time.local_to_utc( time_zone )
          write_attribute(:end_time_utc, raw_end_time_utc)
        end

        def venue_name
          venue[:name]
        end

        def date=(val)
          write_attribute(:date, Date.parse(val))
        end

        # def venue=(val)
        #   write_attribute(:venue_id, val.id)
        #   write_attribute(:venue_name, val.name)
        #   write_attribute(:lat, val.lat) unless lat.nil?
        #   write_attribute(:lng, val.lng) unless lng.nil?
        #   write_attribute(:citycode, val.citycode) unless citycode?
        # end

        def party=(val)
          write_attribute(:party_id, val.id)
          write_attribute(:venue, val.venue)
          write_attribute(:start_time, val.start_time)
          write_attribute(:end_time, val.end_time)
          write_attribute(:user_id, val.user_id)
          write_attribute(:date, val.next_date)
          set_utc(val.next_date, val.start_time, val.length_in_hours)
        end

        def full_address
          venue[:full_address]
        end

        def time_zone
          venue[:time_zone]
        end

        def title_and_venue_name
          "#{title} at #{venue_name}"
        end

        def album_title(album_type=nil)
          txt = "#{date.to_s(:slash)}: #{title} at #{venue_name}"
          album_type = self.image_method(album_type.to_sym) rescue nil
          txt << "(" + album_type["title"] + ")" unless album_type.nil?
          txt
        end

        # def set_to_param
        #   write_attribute :to_param, %Q{#{self.id}-#{[self.title, self.venue.name, self.venue.city, self.venue.state].join(' ').gsub(/[^a-z0-9]+/i, '_')}}
        # end

        def past?
          self.end_time_utc < Time.now.utc
        end

        def uploadable_by_user?(*args)
          self.party.uploadable_by_user?(*args)
        end
      end

      def self.included(receiver)
        attr_accessor *ATTRIBUTES
        receiver.extend         ClassMethods
        receiver.send :include, FCG::Client::Persistence
        receiver.send :include, InstanceMethods
        receiver.validates_presence_of :user_id, :party_id, :venue, :date
        receiver.validates_format_of :start_time, :with => /^(0?[1-9]|1[0-2]):(00|15|30|45)(a|p)m$/i
        receiver.validates_format_of :end_time, :with => /^(0?[1-9]|1[0-2]):(00|15|30|45)(a|p)m$/i
      end
    end
  end
end