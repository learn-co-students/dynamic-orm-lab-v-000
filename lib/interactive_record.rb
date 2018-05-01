require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def initialize(attributes=nil)
    attributes.each{|k, v| self.send("#{k}=", v)} if attributes
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.reject{|name| name == 'id'}.join(', ')
  end

  def values_for_insert
    self.class.column_names.collect do |col_name|
      "'#{self.send(col_name)}'" unless send(col_name).nil?
    end.compact.join(", ")
  end

  def save
    sql = <<~"SQL"
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
      VALUES (#{values_for_insert})
    SQL
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true
    DB[:conn].execute("pragma table_info('#{table_name}')").collect {|row| row["name"]}
  end

  def self.find_by_name(name)
    sql = <<~"SQL"
      SELECT *
      FROM #{table_name}
      WHERE name = ?
    SQL
    DB[:conn].execute(sql, name)
  end

  def self.find_by(attribute)
    sql = <<~"SQL"
      SELECT *
      FROM #{table_name}
      WHERE #{attribute.keys[0].to_s} = ?
    SQL
    # binding.pry
    DB[:conn].execute(sql, attribute.values[0].to_s)
  end
end
