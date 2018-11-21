require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    table = self.to_s.downcase.pluralize
    table
  end

  def self.column_names #returns an array of column names
    sql = <<-SQL
      PRAGMA table_info('#{table_name}')
    SQL

    table_info = DB[:conn].execute(sql)
    column_names = []

    table_info.each do |column|
      column_names << column["name"]
    end
    column_names
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM #{table_name}
      WHERE #{table_name}.name = ?
    SQL

    DB[:conn].execute(sql, name)
  end

  def self.find_by(options = {})
    property = nil
    value = nil

    options.each do |k, v|
      property = k
      value = v
    end

    sql = <<-SQL
      SELECT * FROM #{table_name}
      WHERE #{property.to_s} = ?
    SQL

    DB[:conn].execute(sql, value)
  end

  def initialize(options = {})
    options.each do |property, value|
        self.send("#{property}=", value)
    end
  end

  # instance methods that insert data into the Database
  # INSERT INTO students (name, grade) VALUES ("leo", 12)
  # abstract way to get the table name. we already have self.table_name class method. will need to access this from an instance.
  # abstract way to get the attributes without the id in comma separated format.
  # abstract way to get the values of the attributes.
  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if { |col| col == "id" }.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def save
    sql = <<-SQL
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
      VALUES (#{values_for_insert})
    SQL

    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end
end
