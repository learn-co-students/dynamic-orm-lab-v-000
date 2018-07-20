require_relative "../config/environment.rb"
require "active_support/inflector"

class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    columns = []
    sql = "PRAGMA table_info('#{table_name}')"
    DB[:conn].execute(sql).each do |column|
      columns << column["name"]
    end
    columns.compact
  end

  def initialize(options = {})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.drop(1).join(", ")
  end

  # def values_for_insert
  #   instance_variables.collect { |attr| "'#{instance_variable_get attr}'" }.drop(1).join(", ")
  # end
  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql).each do |column|
      puts "#{column}"
    end
  end

  def self.find_by(anAttribute)
    col = anAttribute.keys[0]
    val = anAttribute[col]
    sql = "SELECT * FROM #{self.table_name} WHERE #{col} = '#{val}';"
    DB[:conn].execute(sql)
  end
end
