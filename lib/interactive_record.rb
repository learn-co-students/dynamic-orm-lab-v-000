require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
    "#{self.to_s.downcase}s"
  end

  def self.column_names
    sql = "pragma table_info('#{table_name}')"
    table_info = DB[:conn].execute(sql)
    columns = []
    table_info.each do |info|
      columns << info["name"]
    end
    columns
  end

  def initialize(args={})

    args.each do |key,value|
      self.send("#{key}=", value)
    end
  end

  def table_name_for_insert
    "#{self.class.table_name}"
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col|
      values << "'#{self.send(col)}'" unless send(col).nil?
    end
    values.join(", ")
  end

  def save
    sql = <<-SQL
    INSERT INTO #{self.class.table_name}
    (#{self.col_names_for_insert})
    VALUES
    (#{self.values_for_insert})
    SQL
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT *
    FROM #{self.table_name}
    WHERE name = "#{name}"
    LIMIT 1
    SQL
    DB[:conn].execute(sql)
  end

  def self.find_by(hash)
    col_name = hash.keys.first
    value = "#{hash.values.first}"
    sql = <<-SQL
    SELECT *
    FROM #{self.table_name}
    WHERE #{col_name} = #{value}
    SQL
    DB[:conn].execute(sql)
  end
end
