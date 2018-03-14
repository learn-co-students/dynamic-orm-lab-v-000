require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def initialize(hash={})
    hash.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def self.table_name
    "#{self.to_s.downcase.pluralize}"
  end

  def self.column_names
    DB[:conn].results_as_hash = true
    sql = "pragma table_info('#{self.table_name}')"
    hash = DB[:conn].execute(sql)
    array = hash.collect {|k| k["name"]}.compact
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|x| x=="id"}.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |x|
      values << "'#{send(x)}'" unless send(x).nil?
    end
    values.join(", ")
  end

  def save
    sql = <<-SQL
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
      VALUES (#{values_for_insert});
    SQL
    DB[:conn].execute(sql)

    sql_2 = <<-SQL
      SELECT last_insert_rowid() FROM #{table_name_for_insert};
    SQL
    self.id = DB[:conn].execute(sql_2)[0][0]
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * 
      FROM #{self.table_name}
      WHERE name = '#{name}';
    SQL
    DB[:conn].execute(sql)
  end

  def self.find_by(hash)
    value = hash.values.first
    tested_value = value.class == Fixnum ? value : "'#{value}'"
    sql = <<-SQL
      SELECT *
      FROM #{self.table_name}
      WHERE #{hash.keys.first} = #{tested_value};
    SQL
    DB[:conn].execute(sql)
  end

end