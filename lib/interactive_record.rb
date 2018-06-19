require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true
    sql = "pragma table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    columns = Array.new
    table_info.each do |row|
      columns << row["name"]
    end
    columns.compact
  end

  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def save
    sql = "
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
      VALUES (#{values_for_insert})
    "

    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|column| column == "id"}.join(", ")
  end

  def values_for_insert
    values = Array.new
    self.class.column_names.each do |column|
      values << "'#{send(column)}'" unless send(column).nil?
    end
    values.join(", ")
  end

  def self.find_by_name(name)
    sql = "
      SELECT * FROM #{self.table_name}
      WHERE name = '#{name}'
    "

    DB[:conn].execute(sql)
  end

  def self.find_by(option={})
    condition = option.map {|key, value| "#{key} = '#{value}'"}.join(" AND ")
    sql = "SELECT * FROM #{self.table_name} WHERE #{condition}"
    DB[:conn].execute(sql)
  end
end
