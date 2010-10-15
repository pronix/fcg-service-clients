require 'thor'
require 'thor/group'
require "active_support/all"
class CreateModel < Thor::Group
  include Thor::Actions
  
  argument :name
  
  desc "Generate model file for FCG Service Client"
  
  def self.source_root
    File.join(File.dirname(__FILE__), "../", "generators", "models")
  end
  
  def model
    @model ||= name.downcase.singularize
  end
  
  def model_pluralize
    @model_pluralize ||= model.pluralize
  end
  
  def klass
    @klass ||= model.classify
  end
  
  def create_model_file
    template('model.tt', "lib/fcg_service_clients/models/#{model}.rb")
  end
  
  def add_to_git
    file = File.join(File.dirname(__FILE__), "../", "lib", "fcg_service_clients", "models", "#{model}.rb")
    system "git add #{file}"
  end
end