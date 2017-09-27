require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true #What is the purpose of this line?
    sql = "PRAGMA table_info('#{table_name}')"
    table_info = DB[:conn].execute(sql)
    table_info.map {|col| col["name"]}.compact
    #=> ["id", "name", "grade"]
  end

  def initialize(options={})
    options.each {|property, value| self.send("#{property}=", value)}
    #=> #<Student:0x00000003a0b448 @grade=11, @id=nil, @name="Sam">
  end

  def table_name_for_insert
    self.class.table_name
    #=> "students"
  end

  def col_names_for_insert #need to remove "id" b/c table creates that; returns an array and need a string
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
    #=> "name, grade"
  end

  def values_for_insert
    #iterate through #col_names array
    values = []
    self.class.column_names.each {|col| values << "'#{send(col)}'" unless send(col).nil?} #id is nil; need values to have single quotes around them ' '
    values.join(", ") #need values to be in a comma separated string
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert}(#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

  def self.find_by(a)
    sql = "SELECT * FROM #{self.table_name} WHERE #{a.keys.join} = '#{a.values.join}'"
    DB[:conn].execute(sql)
  end

end
