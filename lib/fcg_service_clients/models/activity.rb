module FCG
  module Client
    module Activity
      ATTRIBUTES = [:actor, :created_at, :extra, :id, :object, :site, :summary, :target, :title, :verb, :visible]

      module ClassMethods
        
      end

      module InstanceMethods
        # [actor] [verb] [object] [target]
        def create_title
          new_title = [actor_name, verb_in_sentence, object_title]
          new_title << target_title unless target.nil?
          self.title = new_title.join(" ")
        end
        
        def verb_in_sentence
          FCG::ACTIVITY::VERBS::ALL[verb.to_sym]
        end
        
        def actor_name
          actor['display_name']
        end
        
        def object_title
          handle_title.call(object)
        end
        
        def target_title
          handle_title.call(target)
        end
        
        def create_summary
          self.summary = begin
            txt = title
            txt << " at #{site}" unless site.nil?
            txt
          end
        end
        
        def generate_stats
          if self.verb.to_sym == :view
            save_asynchronous
          end
        end
        
        def save_asynchronous
          unless @queue
            @queue = self.class.async_client.queue("stats", :durable => :false)
          end
          @queue.publish(to_json)
        end
        
        private
        def handle_title
          Proc.new{|col| col['title'] || col['name'] || col['display_name'] }
        end
      end

      def self.included(receiver)
        attr_accessor *ATTRIBUTES
        receiver.extend         ClassMethods
        receiver.send :include, FCG::Client
        receiver.send :include, InstanceMethods
        receiver.include_root_in_json = false
        receiver.validates_presence_of :actor, :object, :verb
        receiver.validates_inclusion_of :verb, :in => FCG::ACTIVITY::VERBS::ALL.keys.map(&:to_s)
        receiver.before_save :create_title, :create_summary
        receiver.after_create :generate_stats
      end
    end
  end
end