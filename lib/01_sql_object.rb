require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    if @columns.nil?
      rows = DBConnection.execute2(<<-SQL)
        SELECT
          *
        FROM
          '#{table_name}'
      SQL
      @columns = rows.first.map(&:to_sym)
    else
      @columns
    end
  end

  def self.finalize!
    columns.each do |column|
      define_method("#{column}") { attributes[column] }
      define_method("#{column}=") { |value| attributes[column] = value }
    end
  end

  # set the name of the table for the class
  def self.table_name=(table_name)
    @table_name = table_name
  end

  # get the name of the table for the class
  def self.table_name
    @table_name || self.name.tableize
  end

  def self.all
    rows = DBConnection.execute(<<-SQL)
      SELECT *
      FROM '#{table_name}'
    SQL
    parse_all(rows)
  end

  def self.parse_all(results)
    results.map { |row| self.new(row) }
  end

  def self.find(id)
    rows = DBConnection.execute(<<-SQL, id)
      SELECT *
      FROM '#{table_name}'
      WHERE id = ?
      LIMIT 1
    SQL
    parse_all(rows).first
  end

  def initialize(params = {})
    columns = self.class.columns

    params.each do |name, value|
      name = name.to_sym
      raise "unknown attribute '#{name}'" unless columns.include? name
      self.send("#{name}=", value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map { |col| self.send(col) }
  end

  def insert
    vals = attribute_values
    columns = self.class.columns
    question_marks = (["?"] * columns.length).join(', ')
    col_names = columns.join(', ')

    DBConnection.execute(<<-SQL, *vals)
      INSERT INTO #{self.class.table_name} (#{col_names})
      VALUES (#{question_marks})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    vals = attribute_values
    columns = self.class.columns

    p set_row = columns.map { |col| "#{col} = ?" }.join(', ')

    DBConnection.execute(<<-SQL, *vals, self.id)
      UPDATE #{self.class.table_name}
      SET #{set_row}
      WHERE id = ?
    SQL
  end

  def save
    if self.id.nil?
      insert
    else
      update
    end
  end
end
