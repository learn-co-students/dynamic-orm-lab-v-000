require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'
class InteractiveRecord
  #Class Methods
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

  def self.conditions_for_insert(options = {})
    option_arr = []
    options.each do |property, value|
      if value.is_a?(Integer)
        option_arr << "#{property} = #{value}"
      else
        option_arr << "#{property} = '#{value}'"
      end
    end
    options = option_arr.join(" AND ")
  end

  def self.find_by(options = {})
    sql = <<-SQL
      SELECT * FROM #{table_name}
      WHERE #{conditions_for_insert(options)}
    SQL

    DB[:conn].execute(sql)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM #{table_name}
      WHERE name = '#{name}'
    SQL

    DB[:conn].execute(sql)
  end

  def self.table_name
    self.to_s.downcase.pluralize
  end

  #Instance Methods
  def initialize(properties={})
    properties.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col_name| col_name == "id"}.join(", ")
  end

  def save
    sql = <<-SQL
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
      VALUES (#{values_for_insert})
    SQL
    DB[:conn].execute(sql)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def table_name_for_insert
    self.class.table_name
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end
end
