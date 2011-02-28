module FCG
  module Client
    module Session
      ATTRIBUTES = [:id, :session_id, :data, :expiry, :created_at]

      module ClassMethods

        def find_by_sid(sid)
          request = send_to_server(:method => :get, :path => "#{service_url}/find_by_sid/#{sid}")
          handle_service_response request.handled_response
        end

        # This is modelled after hash-like stores - Memcache etc
        def get(sid)
          find_by_sid(sid)
        end

        def set(sid, new_session, expiry = Time.now.utc)
          update(find_by_sid(sid), :data => new_session, :expiry => expiry)
        end

        def add(sid, session)
          create(:session_id => sid, :data => session)
        end

        def delete(sid)
          find_by_sid(sid).delete
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
