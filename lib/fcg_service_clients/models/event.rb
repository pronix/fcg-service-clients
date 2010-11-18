module FCG
  module Client
    module Event
      ATTRIBUTES = [:active, :comments_allowed, :created_at, :date, :description, :dj, :end_time, :end_time_utc, :flyer_album_id, :host, :length_in_hours, 
        :music, :party_id, :photo_album_id, :posted_to_twitter_at, :start_time, :start_time_utc, :title, :updated_at, :user_id, :venue]

      module ClassMethods
        def upcoming_the_next_7_days
          now = 6.hours.ago(Time.now.utc)
          date_range = now.beginning_of_day..7.days.since(now).end_of_day
          search(:conditions => {:active => true, :start_date => date_range.first.to_i, :end_date => date_range.last.to_i})
        end
        
        def find_by_citycode(citycode, *args)
          opts = args.extract_options!
          params = {
            :state => "past", # past, between, or future
            :time => Time.now.utc,
            :limit => 10,
            :active => true,
            :skip => 0
          }.merge(opts)
          request = Typhoeus::Request.new(
            "#{service_url}/citycode/#{citycode}", :params => params,
            :method => :get)
          request.on_complete do |response|
            response
          end

          self.hydra.queue(request)
          self.hydra.run

          handle_service_response request.handled_response
        end
      end
      
      module InstanceMethods
        def cover_image
          ::Image.find(photos_sorted.first) unless photos.empty?
        end

        def venue_name
          venue[:name]
        end
        
        def party
          @party = ::Party.find attributes.party_id
        end

        def full_address
          "#{venue.address}, #{venue.city}, #{venue.state}, #{venue.zipcode}"
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
        

        def date
          Date.parse(self.raw_attributes[:date])
        end

        def photo_album_title
          txt = date.short_date + ": #{title_and_venue_name}"
          txt << " (#{photo_album[:title]})" if !photo_album.nil? and photo_album.has_key? :title
          txt
        end

        def flyers?
          !flyers.empty?
        end

        def flyers
          # TODO: create flyer model
          []
        end

        def end_time_utc
          Time.parse(self.raw_attributes[:end_time_utc])
        end

        def start_time_utc
          Time.parse(self.raw_attributes[:start_time_utc])
        end
      end

      def self.included(receiver)
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