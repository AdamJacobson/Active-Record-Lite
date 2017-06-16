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
    @columns.each do |column|
      define_method("#{column}") { @attributes["#{column}"] }
      define_method("#{column}=") { |value| @attributes["#{column}"] = value }
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
    # ...
  end

  def self.parse_all(results)
    # ...
  end

  def self.find(id)
    # ...
  end

  def initialize(params = {})
    # ...
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    # ...
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
