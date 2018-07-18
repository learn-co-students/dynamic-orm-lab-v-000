require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord


    def self.table_name
        self.to_s.downcase.pluralize
    end

    def self.column_names
        sql = <<-SQL
            PRAGMA table_info(#{self.table_name})
        SQL
        column_names = []
        DB[:conn].execute(sql).each do |column|
            column_names << column["name"]
        end
        column_names.compact
    end

    def initialize(options = {})
        options.each do |attribute, value|
            self.send("#{attribute}=", value)
        end
    end

    def table_name_for_insert
    end 

end
