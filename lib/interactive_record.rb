require_relative "../config/environment.rb"
require 'active_support/inflector'
#In full disclosure, this is one of the first labs I copy/pasted a lot of the material, simply because why invent the wheel?
class InteractiveRecord

  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |column|
      values << "'#{send(column)}'" unless send(column).nil?
    end
    values.join(", ")
  end

  def table_name_for_insert
    self.class.table_name
  end

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true
    sql = "pragma table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"]
    end
    column_names.compact
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|column| column == "id"}.join(", ")
  end

  def self.find_by_name(name)
    hash = {:name => name}
    self.find_by(hash)
  end

  def self.find_by(property)
    student = {}
    property.select do |key,value|
      sql = "SELECT * FROM #{self.table_name} WHERE #{key} = '#{value}'"
      binding.pry
      student = DB[:conn].execute(sql)
    end
    student
  end
end
