require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "PRAGMA table_info('#{table_name}')"

    val = DB[:conn].execute(sql).map{|col| col["name"]}

    val.each{|col_name| attr_accessor col_name.to_s}
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
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def save
    sql = <<-SQL
    INSERT INTO #{table_name_for_insert}(#{col_names_for_insert}) VALUES (#{values_for_insert})
    SQL

    DB[:conn].execute(sql)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"

    DB[:conn].execute(sql)
  end

  def self.find_by(var)
    # sql = "SELECT * FROM #{self.table_name} WHERE #{column_names[0]} = '#{var.values[0]}' OR #{column_names[1]} = '#{var.values[0]}' OR #{column_names[2]} = '#{var.values[0]}'"
    sql = "SELECT * FROM #{self.table_name} WHERE #{var.keys[0].to_s} = '#{var.values[0]}'"

    DB[:conn].execute(sql)

  end

end
