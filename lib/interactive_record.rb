require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'
class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    sql = <<-SQL
    PRAGMA table_info(#{self.table_name})
    SQL

    DB[:conn].execute(sql).collect do |hash|
      hash["name"]
    end
  end

  self.column_names.each do |column_name|
    attr_accessor column_name.to_sym
  end

  def initialize(attributes={})
    attributes.each {|key, value|
    self.send("#{key}=", value)}
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|name| name == "id"}
  end

  def values_for_insert
    
  end
end
