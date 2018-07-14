require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'
class InteractiveRecord
  def self.table_name
   "#{self.to_s.downcase}s" 
  end #end the table name
  ###########
  def self.column_names
    sql = "pragma table_info('#{table_name}')"
    table = DB[:conn].execute(sql)
    column_names = []
    table.each do |row|
      column_names << row["name"]
    end #end the each
    column_names
  end #end the column_names
  ########################
  def initialize(attributes={})
    attributes.each do |property, value|
      self.send("#{property}=", value)
    end #end the each 
  end #end the init
  ##########
  def table_name_for_insert
    self.class.table_name
  end #end the table name for insert
  ##########
  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end #end the col names
  ############
  def values_for_insert
    values = []
    self.class.column_names.each do |x|
      values << "'#{send(x)}'" unless send(x).nil?
    end
    values.join(", ")
  end# end the values for insert
  #################
  def save
    sql = " 
     INSERT INTO #{table_name_for_insert}
     (#{col_names_for_insert})
     VALUES (#{values_for_insert})
    "
    DB[:conn].execute(sql)
    @id =DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end #end the save method
  ########
  def self.find_by_name(name)
    sql = "SELECT * FROM students WHERE name = ? LIMIT 1"
    DB[:conn].execute(sql,name)
  end #end the find by name
######### 
  def self.find_by(attribute_hash)
    value = attribute_hash.values.first
    formatted_value = value.class == Fixnum ? value : "'#{value}'"
    sql = "SELECT * FROM #{self.table_name} WHERE #{attribute_hash.keys.first} = #{formatted_value}"
    DB[:conn].execute(sql)
  end
end #ends the class