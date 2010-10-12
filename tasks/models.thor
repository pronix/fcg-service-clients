require 'thor'
require 'thor/group'
require "active_support/all"
class CreateModel < Thor::Group
  include Thor::Actions
  
  argument :name
  argument :version
  
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
    template('model.tt', "app/models/#{model}.rb")
  end
end