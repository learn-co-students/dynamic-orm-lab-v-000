require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'
class InteractiveRecord
  def self.find_by_name(name)
    sql = "SELECT * FROM '#{self.table_name}' WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

  def self.find_by(argument)
    value = argument.values.first
    formatted_value = value.class == Fixnum ? value : "'#{value}'"
    sql = "SELECT * FROM #{self.table_name} WHERE #{argument.keys.first} = #{formatted_value};"
    DB[:conn].execute(sql)
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if{|each| each =="id" }.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each {|col| values << "'#{send(col)}'" unless send(col) == nil}
    values.join(", ")
  end

  def self.column_names
    column_names= []
    sql = <<-SQL
      pragma table_info('#{table_name}')
    SQL
    table_info = DB[:conn].execute(sql)
    table_info.map do |row|
      column_names << row["name"]
    end
    column_names.compact
  end

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def save
    sql = <<-SQL
      INSERT INTO #{table_name_for_insert}
      (#{col_names_for_insert})
      VALUES
      (#{values_for_insert})
    SQL
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid()FROM '#{table_name_for_insert}'")[0][0]
  end

  def initialize(attributes={})

    attributes.each do |key, value|
      self.send("#{key}=", value)
    end
    #binding.pry
  end

  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end

end
#DB[:conn].execute()
