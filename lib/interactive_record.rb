require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    sql = "PRAGMA table_info(#{table_name})"
    test = DB[:conn].execute(sql)
    column_names = []
    test.each do |column|
      column_names << column["name"]
    end
    column_names.compact

  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col|
      values << "'#{send(col)}'" unless send(col).nil?
    end
    values.join(", ")
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    student = DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name = ?", name)
  end

  def self.find_by(param)
    value = param.values[0].class == Integer ? param.values[0] : "'#{param.values[0]}'"
    # if param.values[0].class == Integer
    #   value = param.values[0]
    # else
    #   value = "'#{param.values[0]}'"
    # end
    sql = "SELECT * FROM #{self.table_name} WHERE (#{param.keys[0].to_s}) = (#{value})"
    test = DB[:conn].execute(sql)

  end

end
