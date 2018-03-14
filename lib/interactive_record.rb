require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
    
    def initialize(attributes={})
        attributes.each{ |key, value|
            self.send("#{key}=", value)
        }
    end

    def self.table_name
        self.to_s.downcase.pluralize
    end
    
    def self.column_names
        cols = []
        DB[:conn].execute("PRAGMA table_info('#{self.table_name}')").each { |hash|
            hash.each{ |key, value|
                 cols << value if key == "name"
            }   
        } 
       cols.compact
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM #{self.table_name}
            WHERE name = ?
        SQL

        DB[:conn].execute(sql, name)
    end
    
    def self.find_by(attribute)
        keys = attribute.keys
        sql = <<-SQL
            SELECT * FROM #{self.table_name}
            WHERE #{keys[0].to_s} = ?
        SQL

        DB[:conn].execute(sql, attribute[keys[0]])
    end

    def table_name_for_insert
        self.class.table_name
    end

    def values_for_insert
        values = []
        self.class.column_names.each{ |attribute|
            values << "'#{self.send(attribute)}'" if !self.send(attribute).nil?
        }
        values.join(", ")
    end

    def col_names_for_insert
        self.class.column_names.collect{ |column|
            column unless column == "id"
        }.compact.join(", ")
    end

    def save
        if self.id.nil?
            sql = <<-SQL 
                INSERT INTO #{self.table_name_for_insert} 
                (#{self.col_names_for_insert}) VALUES (#{self.values_for_insert})
            SQL
            DB[:conn].execute(sql)
            self.id =  DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.table_name_for_insert}")[0][0] 
            # => [{"last_insert_rowid()"=>3, 0=>3}, {"last_insert_rowid()"=>3, 0=>3}, {"last_insert_rowid()"=>3, 0=>3}]
            #that is, 0th hash in array of hashes and 0th key in that single hash is "last_insert_rowid()", so return value is the id number
        end
    end
    
end