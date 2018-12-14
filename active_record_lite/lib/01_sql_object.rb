require_relative 'db_connection'
require 'active_support/inflector'

# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
  return @columns if @columns
  arr =   DBConnection.execute2(<<-SQL)
  SELECT
    *
  FROM
    #{self.table_name}
SQL
    @columns = arr.first.map {|el| el.to_sym }
  end



  def self.finalize!
    self.columns.each do |col|
      define_method(col) do 
        self.attributes[col]
      end

      define_method("#{col}=") do |arg|
       self.attributes[col] = arg
      #  self.attributes.[]=(col, arg)
      end
    end
  end

  # def name
  #   @name
  # end
  
  # def name=(arg)
  #   @name = arg
  # end

  def self.table_name=(table_name)

    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.all
    data = DBConnection.execute(<<-SQL)
      SELECT
      *
      FROM
        #{self.table_name}
  SQL
  self.parse_all(data)
  end

  def self.parse_all(results)
    results.map  { |hash| self.new(hash) }
  end

  def self.find(id)
    data = DBConnection.execute(<<-SQL, id: id)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{self.table_name}.id = :id
  SQL
    return nil if data.empty? 
    self.new(data.first)
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      attrib = attr_name.to_sym
       raise "unknown attribute '#{attr_name}'" unless self.class.columns.include?(attrib)
      self.send("#{attrib}=", value)
  
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map { |col| col.send(:) }
  end

  def insert
    col_names = self.superclass.columns.join(",")
    question_marks = []
    col_names.length.times do 
      question_marks << "?"
    end


  end

  def update
    # ...
  end

  def save
    # ...
  end
end
