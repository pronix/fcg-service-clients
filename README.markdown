#FCG Service Client

This is the gem used by all FCG sites to interact with FSS (or FCG Service Server). All FCG sites don't access any databases directly. All databases are on the FSS side.

##Setup

To access FSS, you need to include this in the Gemfile
  gem 'fcg-service-clients'

If using Rails, add this to one of the earliest loading files. For example, in config/intializers/00_fcg.rb
  begin
    FCG::Service::Client.configure do |config|
      config.api_key      = "test key"
      config.host         = "127.0.0.1"
      config.port         = "8080" # 80 is the default
    end
  rescue Exception => e
    raise "make sure you have a valid api_key, host, and post for FSC aka FCG Service Client."
  end

###Copyright

Copyright (c) 2011 First Clandestine Group, Inc. See LICENSE for details.