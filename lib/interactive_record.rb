require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def initialize(params = {})
    params.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def values_for_insert
    values = []

    self.class.column_names.each do |col_name|
      values << "'#{self.send(col_name)}'" unless self.send(col_name) == nil
    end

    values.join(", ")
  end

  def save
    sql = <<-SQL
      INSERT INTO #{self.table_name_for_insert} (#{self.col_names_for_insert})
      VALUES (#{self.values_for_insert})
    SQL

    DB[:conn].execute(sql)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.table_name_for_insert}")[0][0]
  end

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    sql = "PRAGMA table_info ('#{self.table_name}')"

    table_data = DB[:conn].execute(sql)

    column_names = []
    table_data.each {|column| column_names << column["name"]}

    column_names.compact
  end

  def self.find_by_name(name)
    self.find_by(name: name)
  end

  def self.find_by(params)
    key = params.keys[0]
    value = params.values[0]
    value_for_selection = value.class == Integer ? value : "'#{value}'"

    sql = <<-SQL
      SELECT * FROM #{self.table_name}
      WHERE #{key} = #{value_for_selection}
    SQL

    DB[:conn].execute(sql)
  end

end
