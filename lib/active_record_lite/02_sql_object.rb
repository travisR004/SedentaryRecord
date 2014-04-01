require_relative 'db_connection'
require_relative '01_mass_object'
require 'active_support/inflector'
require 'debugger'
class MassObject
  def self.parse_all(results)
    parsed_all = []
    results.each do |result|
      object = self.new(result)
      parsed_all << object
    end
    parsed_all
  end
end

class SQLObject < MassObject

  def self.columns
    @column_array ||= begin
      column_array = DBConnection.execute2("SELECT * FROM #{table_name}")
      column_array = column_array.first
      column_array.each do |column|
        define_method(column) { self.attributes[column.to_sym] }
        define_method("#{column}=") { |val| self.attributes["#{column}".to_sym] = val }
      end
      column_array
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    table_name = self.to_s.tableize
    @table_name ||= table_name
  end

  def self.all
    cats = DBConnection.execute(<<-SQL)
      SELECT
      #{table_name}.*
      FROM
      #{table_name}
    SQL
    cat_objects = []
    cats.each do |cat|
      cat_objects << self.new(cat)
    end
    cat_objects
  end

  def self.find(id)
    cat = DBConnection.execute(<<-SQL)
      SELECT
      #{table_name}.*
      FROM
      #{table_name}
      WHERE
      #{table_name}.id = #{id}
    SQL
    cat = cat[0]
    new_object = self.new(cat)
  end

  def attributes
    @attributes ||= {}
  end

  def insert
    col_names = self.attributes.keys.join(", ")

    DBConnection.execute(<<-SQL)
      INSERT INTO
      #{self.class.table_name} (#{col_names})
      VALUES
      ('#{self.attribute_values.join("', '")}')
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def initialize(options = {})
    options.each do |attr_name, value|
      raise "unknown attribute '#{attr_name}'" unless self.class.columns.include?(attr_name.to_s)
      self.attributes[attr_name.to_sym] = value
    end
  end

  def save
    if id.nil?
      self.insert
    else
      self.update
    end
  end

  def update

    DBConnection.execute(<<-SQL)
    UPDATE
    #{self.class.table_name}
    SET 
    #{self.attributes.map{|key,value| "#{key} = '#{value}'"}.join(', ')}
    WHERE #{self.class.table_name}.id = #{self.id}
    SQL
  end

  def attribute_values
    @attributes.values
  end
end


















