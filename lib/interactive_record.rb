require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  
  def self.table_name
    self.class.to_s.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "pragma table_info(#{table_name}"

    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each { |row| column_names << row["name"] }
    column_names.compact
  end

  self.column_names.each { |col_name| attr_accessor col_name.to_sym}

  def initialize(attributes={})
    attributes.each { |attr, value| self.send("#{attr}=", value) }
  end

  def save
    sql = "INSERT INTO #{self.class.table_name} (#{column_names_for_insert}) VALUES (#{values_for_insert});"

    DB[:conn].execute(sql)
    @id = "SELECT MAX(id) FROM #{self.class.table_name};"
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name| 
      values << "#{send(col_name)}" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def column_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def self.find_by_name
    sql = "SELECT * FROM #{self.class.table_name} WHERE name = '#{name}';"
    DB[:conn].execute(sql)
  end

end