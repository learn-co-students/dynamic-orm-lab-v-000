require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def table_name_for_insert
    self.class.table_name
  end

  def self.column_names
    DB[:conn].results_as_hash

    sql = "pragma table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    table_info.collect{|data| data["name"]}
  end

  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end

  def col_names_for_insert
    self.class.column_names.delete_if{|col| col == "id"}.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values.push("'#{send(col_name)}'") if send(col_name)
    end
    values.join(", ")
  end

  def initialize(options={})
    options.each do |key, val|
      self.send("#{key}=", val)
    end
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert}(#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

  def self.find_by(arg)
    key_values = []
    arg.each{|k, v| key_values.push("#{k} = '#{v}'") if v}
    sql = "SELECT * FROM #{table_name} WHERE #{key_values.join(", ")}"
    DB[:conn].execute(sql)
  end
end
