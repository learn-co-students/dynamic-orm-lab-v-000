require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  # returns the column names for the table associated with this class
  def self.column_names
    table_info = DB[:conn].execute("PRAGMA table_info(#{table_name});")
    return table_info.collect {|column| column ["name"]}
  end

  # create attributes accessors from column names
  self.column_names.each do |name|
    self.class.send(:attr_accessor, name)
  end


  def initialize
    # where are the values supposed to come from?
    # what exactly are we doing here..?
    self.column_names.each do |name|
      self.send("#{k}=", v)
    end
  end


end
