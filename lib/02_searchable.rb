require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    keys = params.keys
    values = params.values
    where_line = keys.map { |key| "#{key} = ?"}.join(' AND ')

    rows = DBConnection.execute(<<-SQL, *values)
      SELECT *
      FROM #{table_name}
      WHERE #{where_line}
    SQL
    self.parse_all(rows)
  end
end

class SQLObject
  extend Searchable
end
