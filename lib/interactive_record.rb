require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    sql = "PRAGMA table_info(#{self.table_name})"

    DB[:conn].execute(sql).map do |col_name| 
      col_name["name"]
    end
  end  

  def initialize(options={})
    options.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col_name| col_name == "id"}.join(", ")
  end

  def values_for_insert
    insert = self.class.column_names.reject{|col_name| send(col_name).nil?}
    insert.map {|col_name| "'#{send(col_name)}'"}.join(", ")
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"

    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{table_name} WHERE name = ?"

    DB[:conn].execute(sql, name)
  end
  
  def self.find_by(attribute)
    terms = attribute.map do |key, value| 
      value.class == Fixnum ? "#{key} = #{value}" : "#{key} = '#{value}'"
      end.first
    sql = "SELECT * FROM #{table_name} WHERE #{terms}"

    DB[:conn].execute(sql)
  end

end