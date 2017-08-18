require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  #class methods
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true
    sql = "pragma table_info('#{self.table_name}')"
    table_info = DB[:conn].execute(sql)

    columns = []
    table_info.each do |column|
      columns << column["name"]
    end
    columns.compact
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM #{self.table_name}
      WHERE name = ?
    SQL

    DB[:conn].execute(sql, name)
  end

  def self.find_by(attribute)
    sql = <<-SQL
      SELECT * FROM #{self.table_name}
      WHERE #{attribute.keys.first.to_s} = '#{attribute.values.first}'
    SQL

    DB[:conn].execute(sql)
  end

  #instance methods
  def initialize(attributes={})
    attributes.each do |k,v|
      self.send("#{k}=",v)
    end
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

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def save
    sql = <<-SQL
      INSERT INTO #{self.table_name_for_insert} (#{self.col_names_for_insert})
      VALUES (#{self.values_for_insert})
    SQL

    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.table_name_for_insert};")[0][0]
  end

end
