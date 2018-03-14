require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true
    sql = "pragma table_info(#{self.table_name})"

    column_names = []
    DB[:conn].execute(sql).each do |col|
      column_names << col["name"]
    end
    column_names.compact
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if{|col| col == "id"}.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send("#{col_name}").nil?
    end
    values.join(", ")
  end

  def attr_accessor
    self.class.column_names.each do |col_name|
      attr_accessor col_name.to_sym
    end
  end

  def initialize(options={})
    options.each do |attribute, value|
      self.send("#{attribute}=", value)
    end
  end

  def save
    sql = "INSERT INTO #{self.table_name_for_insert} (#{col_names_for_insert})
    VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
    DB[:conn].execute(sql, name)
  end

  def self.find_by(item)#item is a hash with a single key/value pair
    col_name = item.to_a[0][0].to_s
    value = item.to_a[0][1]
    sql = "SELECT * FROM #{self.table_name} WHERE #{col_name} = ?"
    DB[:conn].execute(sql, value)
  end


end
