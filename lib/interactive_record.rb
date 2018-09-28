require_relative "../config/environment.rb"
require 'active_support/inflector'
require "pry"

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_name
    DB[:conn].execute("PRAGMA table_info(#{table_name})")
  end

  def self.column_names
    column_name.map {|hash| hash["name"]}.compact
  end

  # self.column_names.each {|column| attr_accessor column.to_sym}

  def initialize(attribute_hash={})
    attribute_hash.each do |variable, value|
      self.send("#{variable}=", value)
    end
    self
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|column| column == "id"}.compact.join(", ")
  end

  def values_for_insert
    col_names_for_insert.split(", ").map {|variable| "'#{self.send("#{variable}")}'"}.join(", ")
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert});"

    DB[:conn].execute(sql)
    DB[:conn].results_as_hash = false
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}").flatten.first
    DB[:conn].results_as_hash = true
    self
  end

  def self.find_by_name(name)
    DB[:conn].execute("SELECT * FROM #{table_name} WHERE name = ?", name).flatten
  end

  def self.find_by(attribute)
    sql = "SELECT * FROM #{table_name} WHERE #{attribute.keys[0].to_s} = ?"
    DB[:conn].execute(sql, "#{attribute.values[0]}")
  end


end
