  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true
    sql = "pragma table_info('#{table_name}')"
    table_info = DB[:conn].execute(sql)
    col_names = []
    table_info.each do |row|
      col_names << row["name"]
    end 
    col_names.compact
  end

  self.column_names.each do |col|
    attr_accessor col.to_sym
  end

  def initialize(hash={})
    hash.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def values_for_insert
    values = [] 
    self.class.column_names.each do |col|
      values << "'#{send(col)}'" unless send(col).nil?
    end
    values.join(", ") 
  end

  def save
    sql = "insert into #{table_name_for_insert} (col_names_for_insert) values (values_for_insert)"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("select last_insert_rowid() from #{table_name_for_insert}")[0][0]
  end

  def find_by_name
    
  end

  def find_by
    
  end