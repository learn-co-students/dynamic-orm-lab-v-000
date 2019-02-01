require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

    def self.table_name
        self.name.downcase.pluralize
    end

    def self.column_names
        DB[:conn].results_as_hash = true
        info = DB[:conn].execute("PRAGMA table_info('#{self.table_name}')")

        column_names = info.collect do |hash|
            hash["name"]
        end
        column_names
    end

    def initialize(options={})
        options.each do |key, value|
            self.send("#{key}=", value)
        end
    end

    def self.find_by_name(name)
        DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name = ?", name)

    end

    #CoffeeDust.io method below <3
    def self.find_by(attributes)
        sql = "SELECT * FROM #{self.table_name} WHERE "
        attributes.each.with_index do |hash,i|
            if attributes.length <= 1 || i == attributes.length - 1
                sql << "#{hash[0]} = ?"
                next
            end
            sql << "#{hash[0]} = ? AND "
        end
        DB[:conn].execute(sql, *attributes.values)
    end
    
    def save
        sql = "INSERT INTO #{self.table_name_for_insert} (#{self.col_names_for_insert}) VALUES (#{self.values_for_insert})"
        DB[:conn].execute(sql)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.table_name_for_insert}")[0][0]
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

end