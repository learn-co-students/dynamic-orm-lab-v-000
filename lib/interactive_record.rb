require_relative "../config/environment.rb"
require 'active_support/inflector'

require 'pry'

class InteractiveRecord

  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    col_array = []
    sql = <<-SQL
      PRAGMA table_info('students')
    SQL
    DB[:conn].execute(sql).each { |idx| col_array << idx['name']}
    col_array
  end

  def col_names_for_insert
    self.class.column_names.drop(1).join(', ')
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(', ')
  end

  def table_name_for_insert
    self.class.table_name
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by(attribute_hash)
    value = attribute_hash.values.first
    formatted_value = value.class == Fixnum || Float ? value : "'#{value}'"
    sql = "SELECT * FROM #{self.table_name} WHERE #{attribute_hash.keys.first} = '#{formatted_value}'"
    DB[:conn].execute(sql)
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

  self.column_names.each do |attr|
    attr_accessor attr.to_sym
  end

end

# binding.pry