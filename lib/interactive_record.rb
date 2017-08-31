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
    #returns an array of all the columns name
  end

  def initialize(attributes={})
    attributes.each { |k,v| self.send("#{k}=",v) }
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    #binding.pry
    self.class.column_names
  end

end
