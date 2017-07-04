require_relative "../config/environment.rb"
require 'active_support/inflector'

require 'pry'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    table_info = DB[:conn].execute("PRAGMA table_info('#{table_name}')")

    column_names = table_info.collect do |row|
      row["name"]
    end.compact
  end

  def initialize(attributes={})
    attributes.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def save
    DB[:conn].execute(
      <<~SQL
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
      VALUES (#{values_for_insert})
      SQL
    )

    @id = DB[:conn].execute(
      <<~SQL
      SELECT last_insert_rowid()
      FROM #{table_name_for_insert}
      SQL
      )[0][0]
  end

  def table_name_for_insert
    self.class.table_name
  end

  def values_for_insert
    self.class.column_names.collect do |col_name|
      "'#{send(col_name)}'" unless send(col_name).nil?
    end.compact.join(", ")
  end

  def col_names_for_insert
    self.class.column_names.delete_if{|col| col == "id"}.join(", ")
  end

  def self.find_by_name(name)
    DB[:conn].execute(
      <<~SQL
      SELECT * FROM #{self.table_name}
      WHERE name = '?'
      SQL
      , name
      )
  end

  def self.find_by(attribute={})
    DB[:conn].execute(
      <<~SQL
      SELECT * FROM #{self.table_name}
      WHERE #{attribute.keys[0]} = '#{attribute.values[0]}'
      SQL
      )

  end

end