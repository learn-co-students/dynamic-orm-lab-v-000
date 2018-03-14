require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def initialize(options={})
    options.each {|k, v| self.send("#{k}=", v)}
  end

 def self.table_name
   self.to_s.downcase.pluralize
 end

 def self.column_names
   DB[:conn].results_as_hash = true
   sql = "PRAGMA table_info ('#{table_name}')"
   table_info = DB[:conn].execute(sql)
   column_names = []
   table_info.each {|c| column_names << c["name"]}
   column_names.compact
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|c| c == "id"}.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |c|
      values << "'#{send(c)}'" unless send(c).nil?
    end
    values.join(", ")
  end

  def save
    DB[:conn].execute("INSERT INTO #{self.table_name_for_insert} (#{self.col_names_for_insert}) VALUES(#{self.values_for_insert})")
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.table_name_for_insert}")[0][0]
  end

  def self.find_by(attribute)
    DB[:conn].results_as_hash = true
    DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE #{attribute.keys.join} = '#{attribute.values.join}'")
  end

  def self.find_by_name(name)
    DB[:conn].results_as_hash = true
    DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name = '#{name}'")
  end

end
