require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "pragma table_info('#{table_name}')"
    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each {|row| column_names << row["name"]}
    column_names.compact
  end

  def initialize(options = {})
    options.each {|property, value| self.send("#{property}=", value)}
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each {|col_name| values << "'#{send(col_name)}'" unless send(col_name).nil?}
    values.join(", ")
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{table_name} WHERE name = name"
    DB[:conn].execute(sql)
  end

  def self.find_by(value = {})
    key = value.keys.first
    if value[value.keys.first].is_a?(Integer)
      sql = "SELECT * FROM #{self.table_name} WHERE #{key} = #{value[key]}"
    elsif value[value.keys.first].is_a?(String)
      sql = "SELECT * FROM #{self.table_name} WHERE #{key} = '#{value[key]}'"
    end
    DB[:conn].execute(sql)
  end
  #   arr = value.to_a[0]
  #   if arr[1].is_a?(Integer)
  #     sql = "SELECT * FROM #{self.table_name} WHERE #{arr[0].to_s} = #{arr[1]}"
  #   elsif arr[1].is_a?(String)
  #     sql = "SELECT * FROM #{self.table_name} WHERE #{arr[0].to_s} = '#{arr[1]}'"
  #   end
  #   DB[:conn].execute(sql)
  # end
end
