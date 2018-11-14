require_relative "../config/environment.rb"
require 'active_support/inflector'


class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    sql = "pragma table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    columns = [ ]
    table_info.each do |row|
      columns << row["name"]
    end
    columns.compact
  end

  def self.find_by_name(name)
    sql = <<-SQL
          SELECT *
          FROM #{table_name}
          WHERE name = ?
          SQL
    DB[:conn].execute(sql, name)
  end

  def self.find_by(attr)
    col_name = attr.first[0].to_s
    value = attr.first[1].to_s
    sql = <<-SQL
          SELECT *
          FROM #{table_name}
          WHERE #{col_name} = ?
          SQL
    DB[:conn].execute(sql, value)
  end

  def initialize(options = {})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if{|x| x == "id"}.join(", ")
  end

  def values_for_insert
    values = [ ]

    self.class.column_names.each do |col|
      values << ("'#{send(col)}'") unless send(col).nil?
    end
    values.join(", ")
  end

  def save
    sql = "INSERT INTO #{self.table_name_for_insert} (#{self.col_names_for_insert}) VALUES (#{self.values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.table_name_for_insert}")[0][0]
  end


end
