require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "pragma table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    table_info.map {|row| row["name"]}.compact
  end

  def initialize(options={})
    options.each {|key, value| self.send("#{key}=", value)}
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col_name| col_name == "id"}.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.map do |col_name|
      values << "'#{self.send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def table_name_for_insert
    self.class.table_name
  end

  def save
    sql = "INSERT INTO #{self.table_name_for_insert} (#{self.col_names_for_insert}) VALUES (#{self.values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.table_name_for_insert}")[0][0]
  end

  def self.find_by(info)
    sql = nil
    if info.values[0].class.to_s == "Fixnum"
      sql = "SELECT * FROM #{self.table_name} WHERE grade = #{info.values[0]}"
    else
      sql = "SELECT * FROM #{self.table_name} WHERE name = '#{info.values[0]}'"
    end

    DB[:conn].execute(sql)
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

  def self.table_name
    self.to_s.downcase.pluralize
  end
  
end