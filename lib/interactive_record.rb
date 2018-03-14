require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  #instance methods
  def initialize(parameters={})
    parameters.each do | key, value |
      self.send("#{key}=", value);
    end
  end

  def table_name_for_insert
    "#{self.class.table_name}"
  end

  def col_names_for_insert
    self.class.column_names[1..-1].join(", ");
  end

  def values_for_insert
    columns = self.class.column_names[1..-1];
    columns.collect do | name |
      data = self.send("#{name}")
      str = "\'#{data}\'"
    end.join(", ")
  end

  def save
    sql = <<-SQL
      INSERT INTO #{self.table_name_for_insert} ( #{col_names_for_insert} ) VALUES ( #{values_for_insert} )
    SQL

    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}").first[0]
  end
  #class methods
  def self.table_name
    "#{self.to_s.downcase}s"
  end

  def self.column_names
    sql = "PRAGMA table_info(#{self.table_name})"
    table_info = DB[:conn].execute(sql);

    table_info.collect do | hash |
       hash["name"];
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM #{self.table_name} WHERE name = ?
    SQL

    DB[:conn].execute(sql, name); # returns sql hash data
  end

  def self.find_by(hash_value)
    column_name = hash_value.keys.first.to_s;
    column_value = hash_value.values[0].to_s;
    sql = <<-SQL
      SELECT * FROM #{self.table_name} WHERE #{column_name} = ?
    SQL
    DB[:conn].execute(sql, column_value);
  end

end
