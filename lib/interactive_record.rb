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
    table_info.each do |row|
      column_names << row['name']
    end
    column_names.compact
  end
end

def initialize(opt={})
  opt.each do |key,value|
    self.send("#{key}=",value)
  end

  def save
    sql = <<-SQL
    INSERT INTO #{table_name_for_insert}
    (#{col_names_for_insert}) VALUES (#{values_for_insert})
    SQL

    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def col_names_for_insert
    self.class.column_names.delete_if{|col| col == 'id'}.join(", ")
  end

  def table_name_for_insert
    self.class.table_name
  end

  def values_for_insert
    val = []

    self.class.column_names.each do |col|
      val << "'#{send(col)}'" unless send(col).nil?
    end
    val.join(", ")
  end

  def find_by_name(name)
      sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
      DB[:conn].execute(sql)
    end

    def find_by(attribute)
    sql = "SELECT * FROM students WHERE '#{attribute}'='#{attribute}'"

    DB[:conn].execute(sql)
  end
  end
