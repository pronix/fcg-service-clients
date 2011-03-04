# This monkeypatch proved itself necessary. Pull request to OmniAuth has been sent.
module OmniAuth
  module Strategies
    class OAuth
      def request_phase
        request_token = consumer.get_request_token(:oauth_callback => callback_url)
        session[:oauth] ||= {}
        session[:oauth][name.to_sym] = {:callback_confirmed => request_token.callback_confirmed?, :request_token => request_token.token, :request_secret => request_token.secret}
        puts session.inspect
        r = Rack::Response.new
        r.redirect request_token.authorize_url
        r.finish
      end
    end
  end
end

class Session
  include FCG::Client::Session

  def self.delete(sid)
    session = find_by_sid(sid)
    if session.data.has_key?(sid)
      session.data.delete(key)
      update(session)
    else
      super(session.id)
    end
  end

  def [](key)
    self.data[key]
  end

  def []=(key,value)
    self.data[key] = value
    save
  end

  def clear
    self.data.clear
    save
  end

  def has_key?(key)
    self.data.has_key?(key)
  end

end

