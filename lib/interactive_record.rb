require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def initialize(options = {})
    options.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    sql = "PRAGMA table_info(#{table_name});"
    names = DB[:conn].execute(sql).inject([]) do |memo, column|
      memo << column["name"] unless column["name"].nil?
      memo
    end
    names.compact
  end

  def self.find_by_name(name)
    sql = <<~SQL
    SELECT *
    FROM #{table_name}
    WHERE name = ?;
    SQL
    DB[:conn].execute(sql, name)
  end

  def self.find_by(hsh)
    sql = <<~SQL
      SELECT *
      FROM #{table_name}
      WHERE #{hsh.keys.first.to_s} = ?;
    SQL
    DB[:conn].execute(sql, hsh.values.first)
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.reject { |name| name == "id" }.join(", ")
  end

  def values_for_insert
    cols = self.class.column_names.reject { |name| name == "id" }
    cols.map { |col| "'#{self.send(col)}'" }.join(", ")
  end

  def save
    sql = <<~SQL
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
        VALUES (#{values_for_insert});
    SQL
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert};")[0][0]
    self
  end

end
