require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord #will be superclass to student

  def self.table_name
    #table name is class name, lowercase and pluralized(active_support/inflector?)
    self.to_s.downcase.pluralize
  end

  def self.column_names
    #set hash result
    DB[:conn].results_as_hash = true
    #PRAGMA column info, then assign execution as variable data info
    sql = "PRAGMA table_info('#{table_name}')"
    table_info = DB[:conn].execute(sql)
    column_names = table_info.collect{|row| row["name"]}.compact #compact to avoid nil values
  end

  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert #add class call, then delete any col id entries, and finally join the results back together
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def save #use sql insert, and then get the id
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

  def self.find_by(attribute_hash) #hash format, thus  must access keys and values
    sql = "SELECT * FROM #{self.table_name} WHERE #{attribute_hash.keys.first} = '#{attribute_hash.values.first}'"
    DB[:conn].execute(sql)
  end

end
