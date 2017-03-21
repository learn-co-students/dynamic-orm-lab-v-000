require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

    def self.table_name
      self.to_s.downcase.pluralize
    end

    def self.column_names
      DB[:conn].results_as_hash = true
      sql = "pragma table_info('#{table_name}')"
      info = DB[:conn].execute(sql)
      names = []
      info.each do |row|
        names << row["name"]
      end
      names.compact
    end

    def initialize(options={})
      options.each { |k, v| self.send("#{k}=", v) }
    end

    def save
      sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
      DB[:conn].execute(sql)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    end

    def table_name_for_insert
      self.class.table_name
    end

    def values_for_insert
      values = []
      self.class.column_names.each { |col_name|values << "'#{send(col_name)}'" if !send(col_name).nil? }
      values.join(", ")
    end

    def col_names_for_insert
      self.class.column_names.delete_if {|col| col == "id"}.join(", ")
    end

    def self.find_by_name(name)
      sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
      DB[:conn].execute(sql)
    end

    def self.find_by(atrbt)
      condition = ""
      atrbt.each {|k,v| condition +="#{k} = '#{v}' AND " }
      sql = "SELECT * FROM #{self.table_name} WHERE #{condition[0..-6]}"
      DB[:conn].execute(sql)
    end

end
