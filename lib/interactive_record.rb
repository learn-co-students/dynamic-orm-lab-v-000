require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  def self.table_name
    # Student => students
    self.to_s.downcase.pluralize
  end
  def self.column_names
    # Get the results as a hash (with header names)
    DB[:conn].results_as_hash = true
    # run the PRAGMA to get the details of a table
    sql = "PRAGMA table_info('#{table_name}')"
    # With each row in the pragma get the rows name and compact that to remove any nil
    DB[:conn].execute(sql).collect{|row| row["name"]}.compact
  end
  def self.find_by(params) # will only use the first parameter
    key = params.keys[0]
    value = params[key]
    sql = <<-SQL
      SELECT * FROM #{table_name} WHERE #{key.to_s} = ?;
    SQL
    # binding.pry
    DB[:conn].execute(sql, value)
  end
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM #{table_name} WHERE name = ? LIMIT 1;
    SQL
    DB[:conn].execute(sql, name)
  end

  # INSTANCE FUNCTIONS FOR CHILDREN
  def initialize(options={})
    # set any optins when creating an instance
    options.each {|property, value| self.send("#{property}=", value)}
  end
  # insert the object into the database
  def save
    sql = <<-SQL
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert});
    SQL
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end
  # simplifies the calls to table_name/column_names (what the functions should be called)
  def table_name_for_insert
    self.class.table_name
  end
  def col_names_for_insert
    # explicitly remove id from this call
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end
  # Life lesson, do not protect your code when your boss demands SQL injection
  # def columns_as_?
  #   values_for_insert.split(", ").count.times.collect{"?"}.join(",")
  # end
  def values_for_insert
    self.class.column_names.delete_if {|col| col == 'id'}.collect{|col| "'#{send(col)}'"}.join(", ")
  end
end
