module Records
    module ClassMethods

        def table_name
            self.to_s.downcase.pluralize
        end

        def column_names
            sql = "PRAGMA table_info(#{self.table_name})"
            res = DB[:conn].execute(sql)
            res.map do |item|
                item['name']
            end.compact
        end

        def find_by_name(name)
            sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
            DB[:conn].execute(sql, name)
        end

        def find_by(properties = {})
            cleaned_props = []
            values = []
            acceptable_properties = column_names
            properties.each do |k,v|
                if acceptable_properties.include?(k.to_s)
                    values << v
                    cleaned_props << "#{k} = ?"
                end
            end
            params_to_insert = cleaned_props.join(", ")
            sql = "SELECT * FROM #{table_name} WHERE #{params_to_insert};"
            DB[:conn].execute(sql, values)
        end
    end
    module InstanceMethods

        def table_name_for_insert 
            self.class.table_name
        end

        def col_names_for_insert
            self.class.column_names.delete_if{|i| i == "id"}.join(", ")
        end

        def values_for_insert
            values = []
            self.class.column_names.each do |c|
                values << self.send("#{c}") if !self.send("#{c}").nil?
            end
            clean_values = values.map{|v| v.class == String ? v.gsub('"',"").gsub("'", '').gsub(")", "") : v}
            clean_values.map{|v| "'#{v.to_s}'"}.join(", ")
        end

        def save
            sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
            DB[:conn].execute(sql)
            self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
        end
    end
end