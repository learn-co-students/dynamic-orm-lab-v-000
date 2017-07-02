require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "PRAGMA table_info('#{table_name}')"
    table_info = DB[:conn].execute(sql)

    column_info = []
    table_info.each do |column|
      column_info << column["name"]
    end

    column_info.compact

  end

  self.column_names.each do |column|
    attr_accessor column.to_sym
  end

  def initialize(options={})
    options.each do |k, v|
      self.send("#{k}=", v)
    end
  end

  def col_names_for_insert
    col_names = self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def table_name_for_insert
    self.class.table_name
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col|
      values << "'#{send(col)}'" unless send(col).nil?
    end
    values.join(", ")
  end

  def save
    sql =  <<-SQL
    INSERT into #{table_name_for_insert} (#{col_names_for_insert})
    VALUES (#{values_for_insert})
    SQL
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end


  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

  def self.find_by(attr)
    sql = "SELECT * FROM #{self.table_name} WHERE #{attr.keys[0]} = '#{attr.values[0]}'"
    DB[:conn].execute(sql)
  end
end
