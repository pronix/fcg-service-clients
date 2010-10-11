module FCG
  module Client
    module Event
      ATTRIBUTES = [:active, :citycode, :comments_allowed, :created_at, :date, :description, :dj, :end_time, :end_time_utc, :flyer_album, :flyers, :host, :id, 
        :lat, :length_in_hours, :lng, :music, :party_id, :photo_album, :photos, :posted_to_twitter_at, :start_time, :start_time_utc, :title, :updated_at, :user_id, 
        :venue_id] 

      module ClassMethods
        
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

        def set_utc(date, start_time, hrs)
          raw_start_time = parse_time( date.to_s + " " + start_time )
          end_date_time = hrs.hours.since(raw_start_time)
          write_attribute(:start_time_utc, raw_start_time.local_to_utc( time_zone ))
          raw_end_time_utc = end_date_time.local_to_utc( time_zone )
          write_attribute(:end_time_utc, raw_end_time_utc)
        end

        def venue_name
          @venue_name ||= venue.name
        end

        def date=(val)
          write_attribute(:date, Date.parse(val))
        end

        def venue=(val)
          write_attribute(:venue_id, val.id)
          write_attribute(:lat, val.lat)
          write_attribute(:lng, val.lng)
          write_attribute(:citycode, val.citycode)
        end

        def party=(val)
          @party = val
          write_attribute(:party_id, val.id)
          write_attribute(:title, val.title)
          write_attribute(:user_id, val.user_id)
          write_attribute(:date, val.next_date)
          write_attribute(:start_time, val.start_time)
          write_attribute(:end_time, val.end_time)
          write_attribute(:length_in_hours, val.length_in_hours)
          write_attribute(:dj, val.dj)
          write_attribute(:host, val.host)
          write_attribute(:music, val.music)
          write_attribute(:description, val.description)
          write_attribute(:active, val.active)
          set_utc(val.next_date, val.start_time, val.length_in_hours)
          self.venue = val.venue
        end

        def full_address
          venue.full_address
        end

        def time_zone
          self.venue.time_zone
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

        def past?
          self.end_time_utc < Time.now.utc
        end

        def uploadable_by_user?(*args)
          self.party.uploadable_by_user?(*args)
        end

        def as_json(*args)
          {
            :event => {
              :id => self.id,
              :party_id => self.party_id,
              :created_at => self.created_at ,
              :title => self.title,
              :citycode => self.citycode,
              :venue_id => self.venue_id,
              :venue_name => self.venue_name,
              :date => self.date.slashed,
              :length_in_hours => self.length_in_hours,
              :dj => self.dj,
              :user_id => self.user_id,
              :comments_allowed => self.comments_allowed,
              :music => self.music,
              :description => self.description,
              :host => self.host,
              :end_time => self.end_time ,
              :end_time_utc => self.end_time_utc,
              :start_time => self.start_time,
              :start_time_utc => self.start_time_utc,
              :photo_album_title => self.photo_album_title,
              :photo_album => self.photo_album,
              :flyer_album => self.flyer_album,
              :lng => self.lng,
              :lat => self.lat,
              :active => self.active
            }
          }
        end
      end

      def self.included(receiver)
        attr_accessor *ATTRIBUTES
        receiver.extend         ClassMethods
        receiver.send :include, FCG::Client::Persistence
        receiver.send :include, InstanceMethods
        receiver.send :include, FCG::UserIncludable
        receiver.include_root_in_json = false
        
        receiver.validates_presence_of :user_id, :party_id, :venue_id
        receiver.validates_format_of :start_time, :with => /^(0?[1-9]|1[0-2]):(00|15|30|45)(a|p)m$/i
        receiver.validates_format_of :end_time, :with => /^(0?[1-9]|1[0-2]):(00|15|30|45)(a|p)m$/i
      end
    end
  end
end