require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  
  def self.table_name
      self.to_s_downcase_pluralize
  end
  
end