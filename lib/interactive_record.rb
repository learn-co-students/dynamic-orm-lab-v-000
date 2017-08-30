require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    sql = "pragma table_info('#{table_name}')"
    DB[:conn].execute(sql).collect do |row|
      row["name"]
    end
  end

  def initialize(attributes={})
    attributes.each{|k,v| self.send("#{k}=",v) unless k ="id"}
  end
end
