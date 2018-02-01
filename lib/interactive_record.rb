require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
    def self.table_name
        self.name.to_s.downcase.pluralize
    end

    def self.column_names
        column_info_hashes = 
            DB[:conn].execute("PRAGMA table_info(#{self.table_name});")

        column_names = column_info_hashes.collect do |column_info_hash|
            column_info_hash["name"]
        end

        column_names.compact
    end

    def self.find_by_name(name)
        DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name = ?;", name)
    end

    def initialize(options = {})
        options.each do |key, value|
            send("#{key}=", value)
        end
    end

    def save
        sql = <<-SQL
            INSERT INTO #{table_name_for_insert}
            (#{col_names_for_insert})
            VALUES (#{values_for_insert})
        SQL

        DB[:conn].execute(sql)

        @id = DB[:conn].execute(
            "SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    end

    def table_name_for_insert
        self.class.table_name
    end

    def col_names_for_insert
        self.class.column_names.delete_if {|col| "id" == col}.join(", ")
    end

    def values_for_insert
        self.class.column_names.
        select {|column_name| send("#{column_name}")}.
        collect {|column_name| "'#{send(column_name)}'"}.
        join(", ")
    end
end