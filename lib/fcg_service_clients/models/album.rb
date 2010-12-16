module FCG
  module Client
    module Album
      ATTRIBUTES = [:comments_allowed, :created_at, :date, :image_type, :location_name, :location_hash, :owner_image_count, :owner_images, :owner_images_order, :record, 
        :summary, :title, :total_image_count, :updated_at, :user_id, :user_submitted_image_count, :user_submitted_images, :user_submitted_order]

      module ClassMethods
        def find_or_create(*args)
          opts = args.extract_options!
          album_object = opts[:model].camelize.constantize.find(opts[:id])
          record = [opts[:model].downcase, opts[:id]].join(":")
          image_type = opts[:album_type]
          user_id = (opts[:user].respond_to?(:id) ? opts[:user].id : opts[:user])

          unless album = self.search(:conditions => {:record => record, :image_type => image_type }).first      
            date = case album_object
              when Event
                album_object.date
              else
                Date.today
            end

            # location related information
            location_name, location_hash = case album_object
              when Event
                [album_object.full_address, album_object.venue.to_hash]
              when User
                ["Here, where I am.", {}]
              else
                ["Here", {}]
            end

            title = case album_object
            when Event
              album_object.title
            when User
              album_object.full_name + "s' Photo Album"
            else
              "Photo Album"
            end

            album = self.new(:date => date, :record => record, :image_type => image_type, :user_id => user_id, :owner_images => [], :user_submitted_images => [], 
              :date => date, :location_name => location_name, :location_hash => location_hash, :title => title)
            unless album.save
              raise "Album model not saving: #{album.errors.inspect}"
            end
          end
          album
        end
      end

      module InstanceMethods
        def add_image!(image)
          if is_image_offical?(image)
            self.owner_images << image.id
          else
            self.user_submitted_images << image.id
          end
          self.save
        end

        # official means is the owner of the image a photographer or the album owner?
        def is_image_offical?(image)
          (image.user_id == self.user_id or self.photographers.include?(image.user_id)) ? true : false
        end
      end

      def self.included(receiver)
        receiver.extend         ClassMethods
        receiver.send :include, FCG::Client::Persistence
        receiver.send :include, InstanceMethods
        
        receiver.validates_presence_of :title, :user_id, :date, :image_type, :record
        receiver.validates_length_of :title, :within => 3..100
      end
    end
  end
end