module FCG
  module Client
    module Session
      ATTRIBUTES = [:id, :session_id, :data, :expiry, :created_at].freeze

      module ClassMethods
        def find_by_sid(sid)
          request = send_to_server(:method => :get, :path => "#{service_url}/find_by_sid/#{sid}")
          handle_service_response request.handled_response
        rescue MessagePack::UnpackError
          nil
        end

        # This is modelled after hash-like stores - Memcache etc
        def get(sid)
          find_by_sid(sid)
        end

        def set(sid, new_session, expiry = Time.now.utc)
          if session = find_by_sid(sid)
            session.data.merge!(new_session.data)
            session.expiry = expiry
            update(session)
          else
            add(sid, new_session, expiry)
          end
        end

        def add(sid, session, expiry = Time.now.utc)
          create(:session_id => sid, :data => session, :expiry => expiry)
        end


      end

      module InstanceMethods



      end

      def self.included(receiver)
        receiver.extend         ClassMethods
        receiver.send :include, FCG::Client::Persistence
        receiver.send :include, InstanceMethods
      end
    end
  end
end
