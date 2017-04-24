require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

    def self.table_name
        self.to_s.downcase.pluralize
    end

    def self.column_names
        DB[:conn].results_as_hash = true

        sql = "PRAGMA table_info('#{table_name}')"

        table_info = DB[:conn].execute(sql)
        column_names = []
        
        table_info.each do |column|
            column_names << column["name"]
        end

        column_names.compact
    end

    self.column_names.each do |col_name|
        attr_accessor col_name.to_sym
    end

    def initialize(attributes={})
        attributes.each do |attribute_name, attribute_value|
            self.send("#{attribute_name}=", attribute_value)
        end
    end

    def save
        DB[:conn].execute("INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})")
        self.id = DB[:conn].execute("SELECT last_insert_rowid()")[0][0]
    end

    def table_name_for_insert
        self.class.table_name
    end

    def col_names_for_insert
        self.class.column_names.delete_if {|col| col == "id"}.join(", ")
    end

    def values_for_insert
        values = []

        self.class.column_names.each do |col_name|
            values << "'#{send(col_name)}'" unless send(col_name).nil?
        end
        values.join(", ")
    end

    def self.find_by(hash)
        hash_name = hash.keys[0]
        hash_value = hash[hash_name]
        sql = "SELECT * FROM #{table_name} WHERE #{hash_name.to_s} = ?"
        DB[:conn].execute(sql, hash_value)
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM #{table_name} WHERE name = ?"
        DB[:conn].execute(sql, name)
    end

end