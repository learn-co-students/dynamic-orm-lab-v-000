require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'
class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end
  def table_name_for_insert
    self.class.table_name
  end
def initialize(options={})
  #binding.pry
  options.each do |property, value|
    self.send("#{property}=", value)
  end
end
 def self.column_names
   DB[:conn].results_as_hash = true
   columns = []
   sql = <<-SQL
   PRAGMA table_info(#{self.table_name})
   SQL
   DB[:conn].execute(sql).each do |x|
     columns << x["name"]
   end
   columns.compact
 end
  def col_names_for_insert
    self.class.column_names.delete_if{|x| x == "id" }.join(", ")
  end
  def self.find_by_name(name)
      DB[:conn].results_as_hash = true
      #binding.pry
      sql = <<-SQL
      SELECT * FROM #{self.table_name} WHERE name = ?
      SQL
      student = DB[:conn].execute(sql,name)
  end
  def self._name(name)
    find_by_name(name)
  end
  def values_for_insert
  values = []
  self.class.column_names.each do |col_name|
    values << "'#{send(col_name)}'" unless send(col_name).nil?
  end
  values.join(", ")
  end
  def self.find_by(hash)
    key = ''
    value = ''
    hash.each{|k,v| key = k.to_s}
    hash.each{|k,v| value = v.to_s }
    DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE #{key} = '#{value}'")
  end
  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end
end
